/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

pragma solidity ^0.5.0;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract YFNTStakeCondition {		
	string public name = "YFNT Stake Condition";
	address public owner;
	address public funder;

    IERC20 public yfntToken;	

    uint256 public constant MAX = ~uint256(0);

    bool public _canVIPCUnstakeYFNT = false;
    uint public _yfntVIPCCondition = 5 * 10 ** 17;
    mapping(address => uint) public stakingYFNTVIPCBalance;
    mapping(address => bool) public hasYFNTVIPCStaked;

	constructor(address _yfntTokenAddr) public {
		owner = msg.sender;
		funder = address(0xAdA68a211fD22956b31b1734788F3D1B545Fa6B1);

        yfntToken = IERC20(_yfntTokenAddr);
	}

	/* Stakes Tokens (Deposit): An investor will deposit the DAI into the smart contracts
	to starting earning rewards.
		
	Core Thing: Transfer the DAI tokens from the investor's wallet to this smart contract. */
    function stakeYFNTTokens() public {	
        require(!hasYFNTVIPCStaked[msg.sender], "staked");		
        
		// transfer Mock DAI tokens to this contract for staking
		yfntToken.transferFrom(msg.sender, address(this), _yfntVIPCCondition);

		// update staking balance
		stakingYFNTVIPCBalance[msg.sender] = stakingYFNTVIPCBalance[msg.sender] + _yfntVIPCCondition;

		hasYFNTVIPCStaked[msg.sender] = true;
	}

	function unstakeYFNTTokens() public {	
        require(_canVIPCUnstakeYFNT, "cannotunstaked");		
        require(stakingYFNTVIPCBalance[msg.sender] >= _yfntVIPCCondition, "cannotunstaked");		
        
		// transfer Mock DAI tokens to this contract for staking
		yfntToken.transfer(msg.sender, _yfntVIPCCondition);

		// update staking balance
		stakingYFNTVIPCBalance[msg.sender] = 0;

		hasYFNTVIPCStaked[msg.sender] = false;
	}

    modifier onlyFunder() {
        require(owner == msg.sender || funder == msg.sender, "!Funder");
        _;
    }

	function setFunderWithAddress(address addr) external onlyFunder {	
		funder = addr;
	}

    function setYfntVIPCCondition(uint pAmount) external onlyFunder {	
		_yfntVIPCCondition = pAmount;
	}

    function setCanVIPCUnstakeYFNT(bool pCan) external onlyFunder {	
		_canVIPCUnstakeYFNT = pCan;
	}

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }
}