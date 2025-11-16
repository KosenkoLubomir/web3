pragma solidity ^0.8.30;

import {ERC20} from '../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';
import {Ownable} from '../lib/openzeppelin-contracts/contracts/access/Ownable.sol';

contract ERC20TestToken is ERC20, Ownable {
    constructor() ERC20("LKOS", "LKOS") Ownable(msg.sender){

    }

    function mint(address to, uint256 value) public onlyOwner{
        _mint(to, value);
    }

    function decimals() public pure override returns(uint8){
        return 8;
    }

}
