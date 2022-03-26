/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// File: contracts/locked/VestingContract.sol



pragma solidity ^0.8.0;


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

//OWnABLE contract that define owning functionality
contract Ownable {
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
  constructor() {
    owner = msg.sender;
  }

  /**
    * @dev Throws if called by any account other than the owner.
    */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}

interface ISMG is IERC20{
    function usedUnvestedBalance(address _contributor) external view returns(uint);
    function vestingIncome(address _to, uint _amount) external;
    function paymentIncome(address _to, uint _amount) external;
    function setUnvestedBalance(address _to, uint _amount) external;
    function unvestedBalance(address _to) external view returns(uint);
}

contract VestingContract is Ownable {
    using SafeERC20 for IERC20;

    
    string public constant NAME = "Samurai Legends Vesting Contract"; //name of the contract
    
    mapping(address => uint[]) public roundId;
    mapping(address => mapping(uint => uint)) public boughtTokens;
    mapping(uint => uint) public tgePercentage;
    mapping(uint => uint) public vestingDuration;
    mapping(address => uint) public claimedAmount;

    address public tokenAddress;
    uint public tgeTimestamp;

    // CONSTRUCTOR
    constructor(address _tokenAddress, uint _tgeTimestamp) {
        require(_tokenAddress != address(0), "Vesting Contract: You can't set the zero address as token address");
        tokenAddress = _tokenAddress;
        tgeTimestamp = _tgeTimestamp;
    }

    function setRoundParticipations(address[] calldata _contributor, uint[][] calldata _rounds, uint[][] calldata  _boughtTokens) public onlyOwner{
        require(_contributor.length == _rounds.length && _contributor.length == _boughtTokens.length,"Vesting Contract: Lengths of lists are not the same");
        for(uint i = 0; i < _contributor.length;i++){
            roundId[_contributor[i]] = _rounds[i];
            for(uint j=0; j < _rounds[i].length;j++){
                boughtTokens[_contributor[i]][_rounds[i][j]] = _boughtTokens[i][j];
            }
        }
    }

    function setUnlockData(uint[] calldata _roundId, uint[] calldata _tgeAmount, uint[] calldata _vestingDuration) public onlyOwner{
        require(_roundId.length == _tgeAmount.length && _roundId.length == _vestingDuration.length,"Vesting Contract: The lengths of the lists are not the same");
        for(uint i = 0; i<_roundId.length;i++){
                tgePercentage[_roundId[i]] = _tgeAmount[i];
                vestingDuration[_roundId[i]] = _vestingDuration[i];
        }
    }

    function setTgeTimestamp(uint _timestamp) public onlyOwner{
        tgeTimestamp = _timestamp;
    }

    function getPassedSeconds() public view returns(uint){
        return block.timestamp - tgeTimestamp;
    }

    function getVestedBalanceForRound(address _contributorAddress, uint _roundId) public view returns(uint){
        if(getPassedSeconds() / 2592000  >= vestingDuration[_roundId]){
            return boughtTokens[_contributorAddress][_roundId]; 
        }
        else{
            uint _tgeAmount = (boughtTokens[_contributorAddress][_roundId] * tgePercentage[_roundId]) / 100;
            uint _vestingAmount = ((100-tgePercentage[_roundId]) * getPassedSeconds() * boughtTokens[_contributorAddress][_roundId]) / 100;
            uint _vestingDuration = (vestingDuration[_roundId] * 2592000);
            uint _availableAmount = _tgeAmount + (_vestingAmount / _vestingDuration);
            return _availableAmount;
        }
    }

    function getVestedTotalBalance(address _contributorAddress) public view returns(uint){
        uint _vestedBalance;
        for(uint i = 0;i < roundId[_contributorAddress].length;i++){
            _vestedBalance += getVestedBalanceForRound(_contributorAddress, roundId[_contributorAddress][i]);
        }
        return _vestedBalance;
    }

    function getAvailableBalance(address _contributorAddress) public view returns(uint){
        return getVestedTotalBalance(_contributorAddress) - claimedAmount[_contributorAddress];
    }

    function claimBalance() public{
        uint _availableBalance = getAvailableBalance(msg.sender);
        require(_availableBalance > 0,"Vesting Contract: You don't have any claimable Tokens");
        uint _usedUnvested = ISMG(tokenAddress).usedUnvestedBalance(msg.sender);
        if(_usedUnvested == 0){
            IERC20(tokenAddress).transfer(msg.sender,_availableBalance);
        }
        else if(_availableBalance <= _usedUnvested){
            ISMG(tokenAddress).vestingIncome(msg.sender,_availableBalance);
        }
        else{
            uint _unvestedBalance = ISMG(tokenAddress).unvestedBalance(msg.sender);
            ISMG(tokenAddress).setUnvestedBalance(msg.sender, _unvestedBalance - _availableBalance);
            IERC20(tokenAddress).transfer(msg.sender, _availableBalance - _usedUnvested);
        }
        
        claimedAmount[msg.sender] += _availableBalance;
    }

    function withdrawTokens(address _tokenAddress) public onlyOwner{
        uint _balance = IERC20(_tokenAddress).balanceOf(address(this));
        require(_balance > 0,"Vesting Contract: There is no balance available for this Token");
        IERC20(_tokenAddress).transfer(msg.sender,_balance);
    }
}