/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
	
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
	
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
	
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;
		
        _status = _NOT_ENTERED;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
	
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Referrals is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
	
	event member(address indexed user, address indexed sponsor);
	
	struct mapMyTeam {
	   address sponsor;
    }
	
	struct Team{
      uint256 member;
    }
	
    mapping(address => mapMyTeam) public mapTeamAllData;
	mapping(address => Team[10]) mapTeam;
    mapping(address => bool) public moderators;
	mapping(address => uint256) public downline;
	
    constructor() { }
	
    receive() external payable {}

    function addModerator(address _moderators, bool _status) external onlyOwner {
        moderators[_moderators] = _status;
    }
	
    modifier isModerator() {
        require(moderators[msg.sender] , "!isModOrOwner");
        _;
    }  
	
    function addMember(address teamMember, address sponsor) public isModerator {
	   require(teamMember != address(0), "zero address");
	   require(sponsor != address(0), "zero address");
	   require(teamMember != sponsor, "ERR: referrer different required");
	   require(mapTeamAllData[teamMember].sponsor == address(0), "sponsor already exits");
	   
	   mapTeamAllData[teamMember].sponsor = sponsor;
	   enterTeam(teamMember);
	   
	   emit member(teamMember, sponsor);
    }
	
    function getSponsor(address teamMember) public view returns (address) {
        return mapTeamAllData[teamMember].sponsor;
    }
	
	function enterTeam(address sender) internal{
		address nextSponsor = mapTeamAllData[sender].sponsor;
		uint256 i;
        for(i=0; i < 10; i++) {
			if(nextSponsor != address(0)) 
			{
				downline[nextSponsor] += 1;
				mapTeam[nextSponsor][i].member += 1; 
			}
			else 
			{
				 break;
			}
			nextSponsor = mapTeamAllData[nextSponsor].sponsor;
		}
	}
	
	function getTeam(address sponsor, uint256 level) external view returns(uint256){
        return mapTeam[sponsor][level].member;
    }
}