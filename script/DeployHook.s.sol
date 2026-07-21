// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {HookMiner} from "v4-hooks-public/src/utils/HookMiner.sol";

import {PointsHook} from "../src/PointsHook.sol";

contract DeployHook is Script {
    // Canonical CREATE2 deployer proxy (same address on every chain that has it deployed)
    address constant CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function run() external {
        // Address of the already-deployed v4 PoolManager on the target network
        IPoolManager manager = IPoolManager(vm.envAddress("POOL_MANAGER"));

        // Must match PointsHook.getHookPermissions() exactly, or BaseHook's
        // constructor will revert once the hook is deployed to the mined address
        uint160 flags = uint160(Hooks.AFTER_SWAP_FLAG | Hooks.AFTER_ADD_LIQUIDITY_FLAG);

        bytes memory constructorArgs = abi.encode(manager);
        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, flags, type(PointsHook).creationCode, constructorArgs);

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        PointsHook hook = new PointsHook{salt: salt}(manager);
        require(address(hook) == hookAddress, "DeployHook: mined address mismatch");

        vm.stopBroadcast();

        console.log("PointsHook deployed to", address(hook));
    }
}
