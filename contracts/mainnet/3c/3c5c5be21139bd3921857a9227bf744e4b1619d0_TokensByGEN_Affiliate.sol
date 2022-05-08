/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

// SPDX-License-Identifier: Unlicensed 
// "Unlicensed" is NOT Open Source 
// This contract can not be used/forked without permission 



/*

Affiliate Holder Token for TokensByGEN

TokensByGEN is a Token Generator Tool created by GenTokens. 
Clients pay 1 BNB to create a token (or have an ongoing 1% transaction fee in the contract)

As an affiliate of TokensByGEN, you can earn up to 20% commission.
For full details, visit our website at https://tokensbygen.com/

AFFILIATE COMMISSION RATES

***** Level 1 *****

(hold the affiliate token)

10% of initial 1 BNB payment or 10% of the ongoing 1% transaction fee
10% of the 2 BNB buy out fee (if client wants to remove the 1% transaction fee)

***** Level 2 *****

(hold affiliate token and 500,000+ GEN)

15% of initial 1 BNB payment or 15% of the ongoing 1% transaction fee
15% of the 2 BNB buy out fee (if client wants to remove the 1% transaction fee)

***** Level 3 *****

(hold affiliate token and 1M+ GEN)

20% of initial 1 BNB payment or 20% of the ongoing 1% transaction fee
20% of the 2 BNB buy out fee (if client wants to remove the 1% transaction fee)


Boost your commission by holding more GEN!
GEN CONTRACT ADDRESS: 0x7d7a7f452e04C2a5df792645e8bfaF529aDcCEcf

For more details, visit our website at https://tokensbygen.com/


*/


pragma solidity 0.8.10;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract TokensByGEN_Affiliate { 

    constructor () {_owner = payable(0xD05895EDF847e1712721Cc9e0427Aa26289A6Bc5);}

    modifier onlyOwner {
        require(_owner == msg.sender, "Caller must be owner");
        _;
    }

    // Balances
    mapping (address => uint256) private _tOwned;

    // Owner
    address payable public _owner;

    // Token info
    uint256 private constant _decimals = 0; 
    uint256 private _tTotal = 0; 
    string  private constant _name = "TokensByGEN";
    string  private constant _symbol = "TBG_AFF";

    string public constant Website = "https://tokensbygen.com/";
    string public constant Telegram = "https://t.me/tokensByGEN";
    string public constant YouTube = "https://youtube.com/c/gentokens";
    string public constant Utility = "Holder of this token are official affiliates of TokensByGEN Token generator tool. They will earn up to 20% percentage of all contract generator fees.";



    function owner() public view virtual returns (address) {
        return _owner;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint256) {
        return _decimals;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account];
    }


    // Approve Affiliate
    function Affiliate(address Wallet, uint256 Level) external onlyOwner {
        _tOwned[Wallet] = Level;
    }

    // Approve Affiliate Bulk
    function Affiliate_BULK(address[] calldata Wallet, uint256 Level) external onlyOwner {
        for (uint i=0; i < Wallet.length; i++) {
        _tOwned[Wallet[i]] = Level;
        }
    }


    // Purge BNB
    function purge_BNB() public {
        uint256 BNB = address(this).balance;
        if(BNB > 0){
        _owner.transfer(BNB);
        }
    }

    // Purge Tokens
    function purge_Tokens(address random_Token_Address, uint256 percent_of_Tokens) external onlyOwner returns(bool _sent){
        // Can not purge the native token!
        require (random_Token_Address != address(this), "Can not remove native token, must be processed via SwapAndLiquify");
        if(percent_of_Tokens > 100){percent_of_Tokens = 100;}
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom * percent_of_Tokens / 100;
        _sent = IERC20(random_Token_Address).transfer(msg.sender, removeRandom);

    }

    // Allow contract to receive BNB 
    receive() external payable {}

}