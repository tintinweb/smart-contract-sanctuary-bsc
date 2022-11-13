//SPDX-License-Identifier:Unlicensed
pragma solidity 0.8.17;

import "./standard.sol";

contract Taxable is Standard{

    uint256 public _taxRate;
    string public test = "not excluded";
    mapping(address => bool) private _excludedFromFee;
    event Events(string,address);


    constructor(uint256 totalSupply_,string memory name_,string memory symbol_,address owner_,uint256 taxRate_) Standard(totalSupply_,name_,symbol_,owner_){
 
        _taxRate = taxRate_;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
        ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        uint256 amountAfterFee = calculateFee(from,to,amount);
        _balances[from] = fromBalance - amount;
        _balances[to] += amountAfterFee;
        

        emit Transfer(from, to, amount);

    }

    function calculateFee(address from,address to,uint256 amount_) private returns(uint256) {

        if(!_excludedFromFee[from] || !_excludedFromFee[to]){

            test = "excluded";
            
        }
        
        return amount_;
        

    }

    function excludeFromFee(address account) external onlyOwner{

        _excludedFromFee[account] = true;
        emit Events("Excluded from paying fees", account);
        
    }

    function includeFee(address account) external onlyOwner{

        _excludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) external view returns(bool){

        return _excludedFromFee[account];

    }
}