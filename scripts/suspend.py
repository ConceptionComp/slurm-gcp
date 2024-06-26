#!/usr/bin/env python3

# Copyright (C) SchedMD LLC.
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import logging
import sys
from pathlib import Path

import util
from util import (
    groupby_unsorted,
    log_api_request,
    batch_execute,
    to_hostlist,
    wait_for_operations,
    separate,
    execute_with_futures,
)
from util import lkp, cfg, compute, TPU


filename = Path(__file__).name
LOGFILE = (Path(cfg.slurm_log_dir if cfg else ".") / filename).with_suffix(".log")
log = logging.getLogger(filename)

TOT_REQ_CNT = 1000


def truncate_iter(iterable, max_count):
    end = "..."
    _iter = iter(iterable)
    for i, el in enumerate(_iter, start=1):
        if i >= max_count:
            yield end
            break
        yield el


def delete_instance_request(instance, project=None, zone=None):
    project = project or lkp.project
    request = compute.instances().delete(
        project=project,
        zone=(zone or lkp.instance(instance).zone),
        instance=instance,
    )
    log_api_request(request)
    return request


def stop_tpu(data):
    tpu_nodeset = data["nodeset"]
    node = data["node"]
    tpu = data["tpu"]
    if tpu_nodeset.preserve_tpu and tpu.vmcount == 1:
        log.info(f"stopping node {node}")
        if tpu.stop_node(node):
            return
        log.error("Error stopping node {node} will delete instead")
    log.info(f"deleting node {node}")
    if not tpu.delete_node(node):
        log.error("Error deleting node {node}")


def delete_tpu_instances(instances):
    stop_data = []
    for prefix, nodes in util.groupby_unsorted(instances, lkp.node_prefix):
        log.info(f"Deleting TPU nodes from prefix {prefix}")
        lnodes = list(nodes)
        tpu_nodeset = lkp.node_nodeset(lnodes[0])
        tpu = TPU(tpu_nodeset)
        stop_data.extend(
            [{"tpu": tpu, "node": node, "nodeset": tpu_nodeset} for node in lnodes]
        )
    execute_with_futures(stop_tpu, stop_data)


def delete_instances(instances):
    """delete instances individually"""
    invalid, valid = separate(lambda inst: bool(lkp.instance(inst)), instances)
    if len(invalid) > 0:
        log.debug("instances do not exist: {}".format(",".join(invalid)))
    if len(valid) == 0:
        log.debug("No instances to delete")
        return

    valid_hostlist = util.to_hostlist(valid)
    requests = {inst: delete_instance_request(inst) for inst in valid}

    log.info(f"delete {len(valid)} instances ({valid_hostlist})")
    done, failed = batch_execute(requests)
    if failed:
        for err, nodes in groupby_unsorted(lambda n: failed[n][1], failed.keys()):
            log.error(f"instances failed to delete: {err} ({to_hostlist(nodes)})")
    wait_for_operations(done.values())
    # TODO do we need to check each operation for success? That is a lot more API calls
    log.info(f"deleted {len(done)} instances {to_hostlist(done.keys())}")


def suspend_nodes(nodelist):
    """suspend nodes in nodelist"""
    nodes = nodelist
    if not isinstance(nodes, list):
        nodes = util.to_hostnames(nodes)

    tpu_nodes = []
    for node in nodes[:]:
        if lkp.node_is_tpu(node):
            tpu_nodes.append(node)
            nodes.remove(node)

    delete_instances(nodes)
    delete_tpu_instances(tpu_nodes)


def main(nodelist):
    """main called when run as script"""
    log.debug(f"SuspendProgram {nodelist}")
    nodes = util.to_hostnames(nodelist)

    # Filter out nodes not in config.yaml
    cloud_nodes, local_nodes = lkp.filter_nodes(nodes)
    if len(local_nodes) > 0:
        log.debug(
            f"Ignoring slurm-gcp external nodes '{util.to_hostlist(local_nodes)}' from '{nodelist}'"
        )
    if len(cloud_nodes) > 0:
        log.debug(
            f"Using cloud nodes '{util.to_hostlist(cloud_nodes)}' from '{nodelist}'"
        )
    else:
        log.debug("No cloud nodes to suspend")
        return

    # suspend is allowed to delete exclusive nodes
    log.info(f"suspend {nodelist}")
    suspend_nodes(nodes)


parser = argparse.ArgumentParser(
    description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
)
parser.add_argument("nodelist", help="list of nodes to suspend")
parser.add_argument(
    "--debug",
    "-d",
    dest="loglevel",
    action="store_const",
    const=logging.DEBUG,
    default=logging.INFO,
    help="Enable debugging output",
)
parser.add_argument(
    "--trace-api",
    "-t",
    action="store_true",
    help="Enable detailed api request output",
)


if __name__ == "__main__":
    args = parser.parse_args()

    if cfg.enable_debug_logging:
        args.loglevel = logging.DEBUG
    if args.trace_api:
        cfg.extra_logging_flags = list(cfg.extra_logging_flags)
        cfg.extra_logging_flags.append("trace_api")
    util.chown_slurm(LOGFILE, mode=0o600)
    util.config_root_logger(filename, level=args.loglevel, logfile=LOGFILE)
    log = logging.getLogger(Path(__file__).name)
    sys.excepthook = util.handle_exception

    main(args.nodelist)
