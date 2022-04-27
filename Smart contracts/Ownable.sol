//SPDX-License-Identifier: GPL-3.0-or-later>
pragma solidity ^0.8.7;

contract Ownable{

    modifier ownerOnly {
        require(isOwner(), "You are not allowed");
        _;
    }
    
    modifier notOwner {
        require(!isOwner(), "You are not allowed");
        _;
    }

    address owner;
		
	constructor() {
		owner = msg.sender;
	}
	
    function isOwner() internal view returns(bool) {
        return msg.sender == owner;
    }
}