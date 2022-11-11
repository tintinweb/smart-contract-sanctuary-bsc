/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract CoinCreater{
address public contractOwner;
IBEP20 token;
    constructor( IBEP20 _token) {
        contractOwner = msg.sender;
        token = _token;

                  }

    // // modifer: only token Owner
    modifier onlyContractOwner(){
        require(msg.sender == contractOwner, "Not a contract owner");
        _;
    }
    // return the token balance  
     function balanceOf(address account) public view returns (uint256) {
        return token.balanceOf(account);
    }
    // receive the token amount
      function TransferToken( uint256 amount) public {
          require(balanceOf(msg.sender)>0, "You have zero BUSD in your account!");
          token.transferFrom( msg.sender, address(this), amount);
      }

       // owner of this contract withdraw the any erc20 stored in the contract to own address
    function emergencyWithdraw(IBEP20 _token,uint256 _tokenAmount) external onlyContractOwner {
        _token.transfer(msg.sender, _tokenAmount);
    }

    // owner of this contract withdraw the BNBer stored in the contract to own address
    function emergencyWithdrawBNB(uint256 Amount) external onlyContractOwner {
        payable(msg.sender).transfer(Amount);
    }
}