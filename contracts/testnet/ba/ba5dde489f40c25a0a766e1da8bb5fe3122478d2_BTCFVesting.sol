// SPDX-License-Identifier: GPL-2.0

pragma solidity 0.8.17;
import "./bitcoinf-bep20.sol";

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract BTCFVesting is Context, Ownable, ReentrancyGuard {
    struct VestingSchedule{
        address beneficiary;
        uint256 cliff;
        uint256 totalAmount;
        uint256 cliffAmount;
        uint256 balance;
        uint256 lastRelease;
    }
    BITCOINFUTURE private _token;
    uint[] private vestingSchedulesIds;
    mapping(uint => VestingSchedule) private vestingSchedules;
    uint256 private releasableAmount;
    uint256 private btcfCliffPeriod;
    event VestingCreated   (uint packageId, address beneficiary, uint256 cliff, uint256 totalAmount, uint256 cliffAmount, uint256 lastRelease);
    event VestingOverridden(uint packageId, address beneficiary, uint256 cliff, uint256 totalAmount, uint256 cliffAmount, uint256 lastRelease);
    event Released(uint packageId, uint256 amount);
    event Revoked (uint packageId, uint256 amount);
    
    /**
     * @dev Creates a vesting contract.
     * @param _btcfTokenAddress address of the ERC20 token contract
     */
    constructor(address _btcfTokenAddress) {
        require(_btcfTokenAddress != address(0x0), "BTCFVesting: not allowed address");
        _token = BITCOINFUTURE(_btcfTokenAddress);       
    }

    receive() external payable {}

    fallback() external payable {}

    /**
    * @dev Returns the address of the ERC20 token managed by the vesting contract.
    */
    function getBTCFTokenAddress()
    external
    view
    returns(address){
        return address(_token);
    }

    /**
    * @dev Returns the balance of the ERC20 token managed by the vesting contract.
    */
    function getContractBalance()
    external
    view
    returns(uint256){
        return _token.balanceOf(address(this));
    }

    /**
    * @dev Returns the remaining of the ERC20 token managed by the vesting contract.
    */
    function getReleasableBalance()
    external
    view
    returns(uint256){
        return releasableAmount;
    }

    /**
    * @dev Adds new schedule to the vesting contract.
    */
    function createVestingSchedule(
        uint _packageId,        
        address _beneficiary,
        uint256 _cliff,
        uint256 _totalAmount,
        uint256 _cliffAmount,
        uint256 _lastRelease
    )
        public
        onlyOwner{
        require(
            _token.balanceOf(address(this)) >= releasableAmount + _totalAmount,
            "BTCFVesting: not sufficient tokens for vesting"
        );
        require(_beneficiary != address(0x0), "BTCFVesting: not allowed address");
        require(_packageId > 0, "BTCFVesting: package id must be > 0");
        require(_cliff > 0, "BTCFVesting: cliff period must be > 0");
        require(_totalAmount > 0, "BTCFVesting: total amount must be > 0");
        require(_cliffAmount > 0, "BTCFVesting: cliff amount must be > 0");
        require(_lastRelease > 0, "BTCFVesting: last release must be > 0");

        uint256 _balance = _totalAmount; //first balance = totalAmount
        
        //override old schedule with new parameter, remove old balance
        VestingSchedule storage _oldSchedule = vestingSchedules[_packageId];
        if(_oldSchedule.beneficiary == address(0x0)) {
            vestingSchedules[_packageId] = VestingSchedule(_beneficiary, _cliff, _totalAmount, _cliffAmount, _balance, _lastRelease);
            releasableAmount += _totalAmount;        
            vestingSchedulesIds.push(_packageId);
            emit VestingCreated   (_packageId, _beneficiary, _cliff, _totalAmount, _cliffAmount, _lastRelease);
        } else {
            uint256 _oldBalance = _oldSchedule.balance;
            _oldSchedule.beneficiary = _beneficiary;
            _oldSchedule.cliff = _cliff;
            _oldSchedule.totalAmount = _totalAmount;
            _oldSchedule.cliffAmount = _cliffAmount;
            _oldSchedule.balance = _balance;
            _oldSchedule.lastRelease = _lastRelease;
            releasableAmount += _totalAmount;
            releasableAmount -= _oldBalance;

            emit VestingOverridden(_packageId, _beneficiary, _cliff, _totalAmount, _cliffAmount, _lastRelease);
        }        
    }

    function calculatePackageReleaseAmount(
        uint _packageId
    )
    public
    view
    returns(uint256) {
        VestingSchedule memory _schedule = vestingSchedules[_packageId];
        uint _times = (block.timestamp - _schedule.lastRelease) / _schedule.cliff;
        uint256 _amount = _times * _schedule.cliffAmount;

        //min(_amount, _balance)
        return _amount < _schedule.balance ? _amount : _schedule.balance;
    }

    function getLastPackageLastReleaseDate(
        uint _packageId
    )
    public
    view
    returns(uint256) {
       VestingSchedule memory _schedule = vestingSchedules[_packageId];
       return _schedule.lastRelease;
    }

    /**
    * @notice Release vested amount of tokens.
    * @param _packageId the vesting schedule identifier    
    */
    function release(
        uint _packageId  
    )
        public
        nonReentrant {
        uint256 _releaseAmount = calculatePackageReleaseAmount(_packageId);
        VestingSchedule storage vestingSchedule = vestingSchedules[_packageId];
        bool isBeneficiary = msg.sender == vestingSchedule.beneficiary;
        bool isOwner = msg.sender == owner();
        require( isBeneficiary || isOwner, "BTCFVesting: only beneficiary or owner can release tokens");
        require(_releaseAmount <= vestingSchedule.balance, "BTCFVesting: cannot release tokens, not enough vested tokens");
        require(_releaseAmount > 0, "BTCFVesting: cannot release tokens, zero amount or too soon to withdraw");
        
        releasableAmount -= _releaseAmount;
        require(releasableAmount <= _token.balanceOf(address(this)), "BTCFVesting: not enough tokens");

        vestingSchedule.balance -= _releaseAmount;
        vestingSchedule.lastRelease = block.timestamp;
        address payable beneficiaryPayable = payable(vestingSchedule.beneficiary);
        _token.transfer(beneficiaryPayable, _releaseAmount);
        emit Released(_packageId, _releaseAmount);
    }

    /**
    * @notice Revokes the vesting schedule for given identifier, return tokens to owner
    * @param _packageId the vesting schedule identifier
    */
    function revoke(uint _packageId)
        public
        onlyOwner {
        VestingSchedule storage vestingSchedule = vestingSchedules[_packageId];
        uint256 _revokedAmount = vestingSchedule.balance;
        require(_revokedAmount > 0, "BTCFVesting: zero amount, all released or revoked.");
        
        releasableAmount -= _revokedAmount;
        vestingSchedule.balance = 0;
        address payable beneficiaryPayable = payable(owner());
        _token.transfer(beneficiaryPayable, _revokedAmount);
        emit Revoked(_packageId, _revokedAmount);
    }

    /**
    * @dev Returns the number of vesting schedules managed by this contract.
    * @return the number of vesting schedules
    */
    function getVestingSchedulesCount()
        public
        view
        returns(uint256){
        return vestingSchedulesIds.length;
    }

    /**
    * @notice Returns the vesting schedule information for a given identifier.
    * @return the vesting schedule structure information
    */
    function getVestingSchedule(uint _packageId)
        public
        view
        returns(VestingSchedule memory){
        return vestingSchedules[_packageId];
    }

    /**
    * @notice Withdraw the specified amount if possible.
    * @param amount the amount to withdraw
    */
    function withdraw(uint256 amount)
        public
        nonReentrant
        onlyOwner{
        require(_token.balanceOf(address(this)) - releasableAmount >= amount, "BTCFVesting: not enough withdrawable funds");
        _token.transfer(owner(), amount);
    }    
}