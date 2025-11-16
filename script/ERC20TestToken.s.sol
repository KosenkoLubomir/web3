pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ERC20TestToken} from "../src/ERC20TestToken.sol";

contract CounterScript is Script {
    ERC20TestToken public token;

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("TOKEN_OWNER");
        vm.startBroadcast(pk);

        token = new ERC20TestToken();

        uint8 decimals = token.decimals();

        token.mint(owner, 172000000 * 10 ** decimals);
        token.transferOwnership(owner);

        console.log("Total Supply:", token.totalSupply());



        vm.stopBroadcast();
    }
}
