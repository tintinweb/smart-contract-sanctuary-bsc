/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

/**
 *Submitted for verification at FtmScan.com on 2023-01-09
*/

/*

FFFFF  TTTTTTT  M   M         GGGGG  U    U  RRRRR     U    U
FF       TTT   M M M M       G       U    U  RR   R    U    U
FFFFF    TTT   M  M  M      G  GGG   U    U  RRRRR     U    U
FF       TTT   M  M  M   O  G    G   U    U  RR R      U    U
FF       TTT   M     M       GGGGG    UUUU   RR  RRR    UUUU



						Contact us at:
			https://discord.com/invite/QpyfMarNrV
					https://t.me/FTM1337

	Community Mediums:
		https://medium.com/@ftm1337
		https://twitter.com/ftm1337

	SPDX-License-Identifier: UNLICENSED


	eTHENA.sol

	eTHENA is a Liquid Staking Derivate for veTHE (Vote-Escrowed Thena NFT).
	It can be minted by burning (veTHE) veNFTs.
	eTHENA is an ERC4626 based token, which also adheres to the EIP20 Standard.
	It can be staked with Guru Network to earn pure BNB instead of multiple small tokens.
	eTHENA can be further deposited into Kompound Protocol to mint iTHENA.
	iTHENA is a doubly-compounding interest-bearing veTHE at its core.
	iTHENA uses eTHENA's BNB yield to buyback more eTHENA from the open-market via JIT Aggregation.
	The price (in THE) to mint eTHENA goes up every epoch due to positive rebasing.
	This property gives iTHENA a "hyper-compounding" double-exponential trajectory against raw THE tokens.

*/

pragma solidity ^0.8.17;

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function transfer(address recipient, uint amount) external returns (bool);
	function balanceOf(address) external view returns (uint);
	function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}
interface IeTHENA is IERC20 {
	function mint(address w, uint a) external returns (bool);
}
interface IVotingEscrow {
	struct LockedBalance {
		int128 amount;
		uint end;
	}
	function create_lock_for(uint _value, uint _lock_duration, address _to) external returns (uint);
    function locked(uint id) external view returns(LockedBalance memory);
	function token() external view returns (address);
	function merge(uint _from, uint _to) external;
}

contract eTHENA_Depositor {
	struct LockedBalance {
		int128 amount;
		uint end;
	}
	address public dao;
	IeTHENA public eTHENA;
	IVotingEscrow public veTHE;
	uint public ID;
	uint public supplied;
	uint public converted;
	uint public minted;
	/// @notice ftm.guru simple re-entrancy check
	bool internal _locked;
	modifier lock() {
		require(!_locked,  "Re-entry!");
		_locked = true;
		_;
		_locked = false;
	}
	modifier DAO() {
		require(msg.sender==dao, "Unauthorized!");
		_;
	}
	event Deposit(address indexed, uint indexed, uint, uint, uint);
	function deposit(uint _id) public lock {
		uint _ts = eTHENA.totalSupply();
		IVotingEscrow.LockedBalance memory _main = veTHE.locked(ID);
		require(_main.amount > 0, "Dirty veNFT!");
		int _ibase = _main.amount;	//pre-cast to int
		uint256 _base = uint256(_ibase);
		veTHE.merge(_id,ID);
		IVotingEscrow.LockedBalance memory _merged = veTHE.locked(ID);
		int _in = _merged.amount - _main.amount;
		require(_in > 0, "Dirty Deposit!");
		uint256 _inc = uint256(_in);//cast to uint
		supplied += _inc;
		converted++;
		// If no eTHENA exists, mint it 1:1 to the amount of THE present inside the veNFT deposited
		if (_ts == 0 || _base == 0) {
			eTHENA.mint(msg.sender, _inc);
			emit Deposit(msg.sender, _id, _inc, _inc, block.timestamp);
			minted+=_inc;
		}
		// Calculate and mint the amount of eTHENA the veNFT is worth. The ratio will change overtime,
		// as eTHENA is minted when veTHE are deposited + gained from rebases
		else {
			uint256 _amt = (_inc * _ts) / _base;
			eTHENA.mint(msg.sender, _amt);
			emit Deposit(msg.sender, _id, _inc, _amt, block.timestamp);
			minted+=_amt;
		}
	}
	function initialize(uint _id) public DAO lock {
		IVotingEscrow.LockedBalance memory _main = veTHE.locked(_id);
		require(_main.amount > 0, "Dirty veNFT!");
		int _iamt = _main.amount;
		uint _amt = uint(_iamt);
		eTHENA.mint(msg.sender, _amt);
		ID = _id;
	}
	function setDAO(address d) public DAO {
		dao = d;
	}
	function setID(uint _id) public DAO {
		ID = _id;
	}
	function rescue(address _t, uint _a) public DAO lock {
		IERC20 _tk = IERC20(_t);
		_tk.transfer(dao, _a);
	}
	constructor(address ve, address e) {
		dao=msg.sender;
		veTHE = IVotingEscrow(ve);
		eTHENA = IeTHENA(e);
	}
}

/*
	Community, Services & Enquiries:
		https://discord.gg/QpyfMarNrV

	Powered by Guru Network DAO ( 🦾 , 🚀 )
		Simplicity is the ultimate sophistication.
*/