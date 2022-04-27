//SPDX-License-Identifier: GPL-3.0-or-later>
pragma solidity ^0.8.7;

contract Wallet{
    
    event moneyReceived(address _sender, uint _amount);
    event moneyWithdrawed(address _to, uint _amount);

    modifier ownerOnly {
        require(isOwner(), "You are not allowed");
        _;
    }
    
    modifier notOwner {
        require(!isOwner(), "You are not allowed");
        _;
    }

    function isOwner() internal view returns(bool) {
        return msg.sender == owner;
    }

    address owner;
    uint public balance;
    
    constructor(){
        owner = msg.sender;
    }

    function receiveMoney() public payable {
        balance += msg.value;
        emit moneyReceived(msg.sender, msg.value);
    }

    function withdrawMoneyTo(address _to, uint _amount) public ownerOnly virtual {
        require(balance >= _amount, "You don't have enough funds");
        balance -= _amount;
        payable(_to).transfer(_amount);
        emit moneyWithdrawed(_to, _amount);
    }
    
    receive () external payable {
        receiveMoney();
    }
    fallback () external payable {
        receiveMoney();
    }
}