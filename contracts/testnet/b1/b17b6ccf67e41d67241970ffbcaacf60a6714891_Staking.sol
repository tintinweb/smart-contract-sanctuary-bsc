// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './IERC721A.sol';

interface ITRC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;

        require(c / a == b);

        return c;
    }

    /**

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);

        uint256 c = a - b;

        return c;
    }

    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;

        require(c >= a);

        return c;
    }

    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);

        return a % b;
    }
}

contract Ownable   {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor()  {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);
    }

    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {
        return _owner;
    }

    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;
    }

    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }
}


contract Staking is Ownable{
    using SafeMath for uint256;
    ITRC20 public Token;
    IERC721A public NFT;

    struct Stake{
        uint _tokens;
        uint[] _NFTs;
        uint _days;
        uint _stakeTime;
    }
    
    uint256 public minimumERC20Deposit = 100;
    uint256 public time = 1 days;
    uint256 public minimumNFT = 25;
    uint256 public maximumNFT = 1000;

    mapping (address => Stake[]) public stakesOf;
    mapping(uint256 => uint256) public allocation;
    mapping(address => uint256) public commulativeDepositTokensOf;
    mapping(address => uint256) public commulativeWithdrawTokensOf;
    mapping(uint256 => bool) public isNFTStaked;

    event Deposite(address indexed to,address indexed From, uint256 amount, uint256 day,uint256 time);

    constructor(ITRC20 _tokenaddr, IERC721A _nftaddr)  {
        Token = _tokenaddr;
        NFT = _nftaddr;
        _paused = false;
    }

    function checkOwner(uint256[] memory _tokenID) public view returns(bool success){
        for (uint256 i; i < _tokenID.length; i++){
            require(NFT.ownerOf(_tokenID[i]) == msg.sender,"You don't own this nft id!");
        }
        return success = true;
    }

    function checkisStaked(uint256[] memory _tokenID) public view returns(bool success ){
         for(uint256 i=0; i < _tokenID.length; i++){
            require(isNFTStaked[_tokenID[i]] == false,"You already staked these nft ids!");
        }
         return success=true;
    }

    

    function farm(uint256 _amount, uint256 _lockableDays, uint256[] memory _tokenIDs) public whenNotPaused{    
        address caller = msg.sender; // to save gas fee

        require(_tokenIDs.length > minimumNFT && _tokenIDs.length < maximumNFT, "length is not valid");
        require(checkOwner(_tokenIDs) == true);
        require(checkisStaked(_tokenIDs) == true);
        require(_amount >= minimumERC20Deposit, "Invalid amount");

        // take tokens from caller
        Token.transferFrom(caller, address(this), _amount);

        // update state data.
        stakesOf[caller].push(Stake({
            _tokens: _amount, 
            _NFTs: _tokenIDs, 
            _days: _lockableDays,
            _stakeTime: block.timestamp
        }));
        commulativeDepositTokensOf[caller] += _amount;

        // mark staked true for given NFT IDs
        for(uint256 i;i<_tokenIDs.length;i++){
            isNFTStaked[_tokenIDs[i]] = true;
        }

        emit Deposite(caller,address(this),_amount,_lockableDays,block.timestamp);
    }
    
    
    function harvest(uint256 _index) public whenNotPaused{
        uint currentTime = block.timestamp; // to save gas fee.
        address caller = msg.sender; // to save gas fee.

        Stake[] memory _userAllStakes = stakesOf[caller];
        Stake storage _userData = stakesOf[caller][_index];

        require(_userData._tokens != 0, "Already Unstaked");
        require(_index <= _userAllStakes.length, "Invalid index number");
        require(currentTime >= (_userData._days * time + _userData._stakeTime), "Can't unstake before time");

        // calculate reward
        uint reward = calculateReward(caller, _index);
        
        // mark staking false for give NFT IDs.
        unstakeData(_userData._NFTs);

        // send staked ERC20 tokens + reward tokens back to the staker.
        uint256 totalWithdraw = _userData._tokens + reward; 
        Token.transfer(caller, totalWithdraw);
        commulativeWithdrawTokensOf[caller] += totalWithdraw;

        // reset all the state data for given index.
        delete _userData._tokens;
        delete _userData._NFTs;
        delete _userData._days;
        delete _userData._stakeTime;
    }


    function calculateReward(address _owner, uint _index) public view returns (uint reward){
        Stake memory _userData = stakesOf[_owner][_index];

        uint _NFTsCount = _userData._NFTs.length;
        uint _daysCount = _userData._days;
        uint _tokensCount = _userData._tokens;

        // calculate reward based on the given conditions.
        if(_NFTsCount >= 500){
            if(_daysCount == 30){
                reward = _tokensCount * 32 / 100;
            }
            else if (_daysCount == 90){
                reward = _tokensCount * 39 / 100;
            }
            else if (_daysCount == 180){
                reward = _tokensCount * 47 / 100;
            }
            else if (_daysCount == 360){
                reward = _tokensCount * 55 / 100;
            }
        }
        else if(_NFTsCount >= 200){
            if(_daysCount == 30){
                reward = _tokensCount * 27 / 100;
            }
            else if (_daysCount == 90){
                reward = _tokensCount * 34 / 100;
            }
            else if (_daysCount == 180){
                reward = _tokensCount * 41 / 100;
            }
            else if (_daysCount == 360){
                reward = _tokensCount * 47 / 100;
            }
        }
        else if(_NFTsCount >= 150){
            if(_daysCount == 30){
                reward = _tokensCount * 23 / 100;
            }
            else if (_daysCount == 90){
                reward = _tokensCount * 28 / 100;
            }
            else if (_daysCount == 180){
                reward = _tokensCount * 34 / 100;
            }
            else if (_daysCount == 360){
                reward = _tokensCount * 39 / 100;
            }
        }
        else if(_NFTsCount >= 100){
            if(_daysCount == 30){
                reward = _tokensCount * 18 / 100;
            }
            else if (_daysCount == 90){
                reward = _tokensCount * 23 / 100;
            }
            else if (_daysCount == 180){
                reward = _tokensCount * 27 / 100;
            }
            else if (_daysCount == 360){
                reward = _tokensCount * 32 / 100;
            }
        }
        else if(_NFTsCount >= 75){
            if(_daysCount == 30){
                reward = _tokensCount * 16 / 100;
            }
            else if (_daysCount == 90){
                reward = _tokensCount * 20 / 100;
            }
            else if (_daysCount == 180){
                reward = _tokensCount * 24 / 100;
            }
            else if (_daysCount == 360){
                reward = _tokensCount * 28 / 100;
            }
        }
        else if(_NFTsCount >= 50){
            if(_daysCount == 30){
                reward = _tokensCount * 14 / 100;
            }
            else if (_daysCount == 90){
                reward = _tokensCount * 17 / 100;
            }
            else if (_daysCount == 180){
                reward = _tokensCount * 20 / 100;
            }
            else if (_daysCount == 360){
                reward = _tokensCount * 24 / 100;
            }
        }
        else if(_NFTsCount >= 25){
            if(_daysCount == 30){
                reward = _tokensCount * 11 / 100;
            }
            else if (_daysCount == 90){
                reward = _tokensCount * 14 / 100;
            }
            else if (_daysCount == 180){
                reward = _tokensCount * 17 / 100;
            }
            else if (_daysCount == 360){
                reward = _tokensCount * 20 / 100;
            }
        }
        else {
            if(_daysCount == 30){
                reward = _tokensCount * 11 / 100;
            }
            else if (_daysCount == 90){
                reward = _tokensCount * 14 / 100;
            }
            else if (_daysCount == 180){
                reward = _tokensCount * 17 / 100;
            }
            else if (_daysCount == 360){
                reward = _tokensCount * 20 / 100;
            }
        }
    }

    // function to mark stake false for the given NFT IDs.
    // Note: This function can only be called within harvest function.
    function unstakeData(uint[] memory _tokenIDs) internal {
        for (uint i; i < _tokenIDs.length; i++) {
            isNFTStaked[_tokenIDs[i]] = false;
        }
    }

    // return all the staked information of given user in the form of array.
    function UserInformation(address _addr) public view returns(Stake[] memory _userData){
        return stakesOf[_addr];
    }

    // return all the desposited and withDrawn ERC20 tokens count for a specific user.
    function UserERC20Information(address _addr) public view returns(uint256, uint256){
        return (commulativeDepositTokensOf[_addr], commulativeWithdrawTokensOf[_addr]);
    }

    function emergencyWithdraw(uint256 _token) external onlyOwner {
         Token.transfer(msg.sender, _token);
    }
    function emergencyWithdrawBNB(uint256 Amount) external onlyOwner {
        payable(msg.sender).transfer(Amount);
    }

    // function to change the time according to the seconds of one day.
    function changetime(uint256 _time) external onlyOwner{
        time = _time;
    }

    function changeMinimmumAmount(uint256 amount) external onlyOwner{
        minimumERC20Deposit = amount;
    }

    function setMinMaxNFT(uint256 _min,uint256 _max) external onlyOwner{
        maximumNFT = _max;
        minimumNFT = _min;
    }
    
// tokenaddr (address): 0x208F521710620d417E9f35a37f107e360f4A7c3d
// _nftaddr (address): 0x98c4b47dd4987e96256a2616060d212f19246c7a
    
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
   

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function Pause() external onlyOwner{
        _paused=true;
    }
     function UnPause() external onlyOwner{
        _paused=false;
    }
}