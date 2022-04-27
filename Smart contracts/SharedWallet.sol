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

contract SharedWallet is Wallet{ 
    event allowanceAdded(address _to, uint _amount, uint totalAllowance);
    event allowanceReduced(address _to, uint _amount, uint totalAllowance);
    event allowanceWithdrawed(address _to, uint _amount, uint totalAllowance);

    modifier ownerOrAllowed(){
        require(isOwner() || allowances[msg.sender] > 0, "You are not allowed");
        _;
    }

    mapping(address => uint) allowances;

    constructor(){
        allowances[msg.sender] = type(uint).max;
    }

    function getAllowanceValue() public view returns(uint){
        if(isOwner()) return balance;
        return allowances[msg.sender];
    }

    function addAllowance(address _allowed) public payable ownerOnly {
        allowances[_allowed] += msg.value;
        receiveMoney();
        emit allowanceAdded(_allowed, msg.value, allowances[_allowed]);
    }

    function reduceAllowance(address _allowed, uint _amount) public ownerOnly {
        require(allowances[_allowed] >= _amount, "Can't reduce a bigger amount than the actual allowance.");
        
        allowances[_allowed] -= _amount;                
        emit allowanceReduced(_allowed, _amount, allowances[_allowed]);
    }

    function withdrawMoney(uint _amount) public ownerOrAllowed {
        require(allowances[msg.sender] >= _amount, "You don't have enough funds.");
        if(!isOwner()){
            reduceAllowance(msg.sender, _amount);
        }

        withdrawMoneyTo(msg.sender, _amount);
    }   
}