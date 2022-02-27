//SPDX-License-Identifier:MIT
pragma solidity ^0.5.0;
import "./IBEP20.sol";
import "./IERC20.sol";

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract mintWhitelist{
	
	  uint mtcToExtPrice;
    uint maxExtTokenGet;
    address publicAccount;
    address ExtContract;
    address MtcContract;
    mapping(address=>uint) whitelist;

    constructor() public{
    	  mtcToExtPrice = 10; // 1 mtc = 0.1EXT
        maxExtTokenGet = 200; // 200 EXT is the upper limit
        publicAccount = msg.sender;
        ExtContract = address(0x3916FDe777b0BDEFD32E577F9EECDc0011b4c020);
        MtcContract = address(0x956aDF70E5E4FECf31b3619e2c7fE3a5B0796B51);
        whitelist[address(0x0f8095CA25259204aec50bF58C2D9423e0F11671)] = maxExtTokenGet * 10**18;
        whitelist[address(0x1Be08bE28D80CF5Cb70837e7244fa20D006E3F52)] = maxExtTokenGet * 10**18;
    }

    modifier onlyWhitelist{
        require(whitelist[msg.sender]>0,"You have no remaining quota or you are not in the whitelist!");
        _;
    }

    modifier onlyOwner{
        require(msg.sender == publicAccount,"You have no permission to do this action!");
        _;
    }

    function exchange(uint takeAmount) onlyWhitelist public{
        uint giveAwayAmount = takeAmount * mtcToExtPrice;
        require(IERC20(MtcContract).balanceOf(msg.sender)>=giveAwayAmount,"You have no enough money!");
        require(whitelist[msg.sender]>=takeAmount,"Investment limit exceeded!");
        require(IBEP20(ExtContract).balanceOf(address(this))>=giveAwayAmount,"There's no enough EXT to exchange!");
        require(IERC20(MtcContract).transferFrom(msg.sender,address(this),giveAwayAmount),"transaction failed2");
        require(IBEP20(ExtContract).transfer(msg.sender,takeAmount),"transaction failed3");
		    whitelist[msg.sender] = SafeMath.sub(whitelist[msg.sender],takeAmount);
    }
	
	function readAllowance() public view returns(uint){
		return IERC20(MtcContract).allowance(address(this),address(this));
	}
	
    function withdrawMtc() onlyOwner public {
        require(IERC20(MtcContract).balanceOf(address(this))>0,"There's no balance in this contract!");
        IERC20(MtcContract).transfer(msg.sender,IERC20(MtcContract).balanceOf(address(this)));
    }
    function whithdrawExt() onlyOwner public{
        require(IBEP20(ExtContract).balanceOf(address(this))>0,"There's no balance in this contract!");
        IBEP20(ExtContract).transfer(msg.sender,IBEP20(ExtContract).balanceOf(address(this)));
    }
}