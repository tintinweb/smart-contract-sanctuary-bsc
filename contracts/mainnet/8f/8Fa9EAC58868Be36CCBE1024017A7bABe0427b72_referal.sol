/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Ownable {
    address private _owner;
     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _owner = msg.sender;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract referal is Ownable {
    mapping(address => uint256) public totalPaid;
    address public Admin_Wallet = 0x9D48dcb5C1107a67C18Fa2e9aD42996DC36944b2;// admin wallet here
    uint256 public totalRaisedAmount = 0; // total raised amount
    address public Zepx_Address = 0x0Af7aeE626B2641cb1c91c4D42F903D37D88148F;// zepx address here
    address public Busd_Address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // usdt adress here

    function Join_Referral(uint256 Busd_Amount) public {
        require(Busd_Amount >= 0, "sorry incorect amount");
        IERC20 busd = IERC20(
            address(Busd_Address) // usdt Token address
        );
        busd.transferFrom(msg.sender, Admin_Wallet, Busd_Amount);
        totalPaid[msg.sender] = Busd_Amount;
        totalRaisedAmount = totalRaisedAmount + Busd_Amount;
    }

  function Change_Admin_Wallet (address New_Admin_Wallet) external onlyOwner{
      Admin_Wallet = New_Admin_Wallet;
  }

  function Change_Zepx_Adrdress (address New_Zepx_Address) external onlyOwner{
      Zepx_Address = New_Zepx_Address;
  }

  function Change_Usdt_Adrdress (address New_Busd_Address) external onlyOwner{
      Busd_Address = New_Busd_Address;
  }

    function Transfer_Sold_Zepx_ (uint256 Zepx_Amount, address UserAddress) external onlyOwner{
        require(Zepx_Amount >= 0, "sorry incorect amount");
         IERC20 Zepx = IERC20(
            address(Zepx_Address) // Zepx Token address
        );
        Zepx.transfer(UserAddress, Zepx_Amount);
    }
}