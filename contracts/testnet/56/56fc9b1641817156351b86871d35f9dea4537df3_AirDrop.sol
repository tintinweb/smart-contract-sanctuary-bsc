/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

pragma solidity 0.8.9;


// SPDX-License-Identifier:MIT



interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract AirDrop {
	
    IBEP20 public oldToken;
    IBEP20 public newToken;
    address public oldTokenAddress;
    address public newTokenAddress;    
    address payable public owner;
    
     mapping(address=>bool)public taken;

	constructor(address payable _owner,address _oldToken,address _newToken)  {
	    owner=_owner;
        oldTokenAddress=_oldToken;
        newTokenAddress=_oldToken;
        oldToken=IBEP20(_oldToken);
        newToken=IBEP20(_newToken);
	}

	modifier onlyOwner(){
	    require(msg.sender==owner,"access denied");
	    _;
	}
	
    function ReclaimAirdrop()public  returns(bool){
        require(oldToken.balanceOf(msg.sender)>0,"You have 0 amount");
        require(!taken[msg.sender],"you have already taken new tokens");
        uint256 tokens=oldToken.balanceOf(msg.sender);
        newToken.transferFrom(owner,msg.sender,tokens);
        taken[msg.sender]=true;
        return true;
    }
}