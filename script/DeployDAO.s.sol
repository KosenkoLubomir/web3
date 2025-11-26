pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {DAOContract} from "../src/DAOContract.sol";

contract LKosDAOScript is Script {


    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);

        DAOContract dao = new DAOContract(
            0x97412De1d3cd940A8165A3Ad78b1869168966cFa,
            100 * 10**18,
            3 days
        );

        console.log("DAO deployed at:", address(dao));





        vm.stopBroadcast();
    }
}
