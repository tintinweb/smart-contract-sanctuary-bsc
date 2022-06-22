/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

//SPDX-License-Identifier: NOLICENSE
pragma solidity 0.8.14; 

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract LendingStorage {
    struct ReservedData {
        uint256 supplyInReserve;
        uint256 borrowTotal;
        uint256 liquidationThreshold;
        uint256 interestForReserve;
        uint256 interestPeriod;
        uint256 baseLTV;
        bool isActive;
    }

    struct ReservedInfo {
        address[] reserve;
        mapping(address => uint) position;
    }

    ReservedInfo reservedInfo;    
    mapping(address => ReservedData) reserved;
    mapping(address => bool) authorizedBorrower;

    modifier onlyAuthorizedBorrows(address borrower) {
        require(authorizedBorrower[borrower],"Only authorized borrows");
        _;
    }

    modifier onlyReserves(ReservedData memory reserves){
        require(reserves.isActive,"only active reserves");
        _;
    }

    function _configureReserve(address reserve, uint256 lt, uint256 ltv, uint256 interest, uint256 lendingPeriod) internal {
        reserved[reserve] = ReservedData({
            supplyInReserve : 0,
            borrowTotal : 0,
            liquidationThreshold : lt,
            interestForReserve : interest,
            interestPeriod : lendingPeriod,
            baseLTV : ltv,
            isActive : true
        });

        uint index = reservedInfo.reserve.length;
        reservedInfo.reserve.push(reserve);
        reservedInfo.position[reserve] = index;
    }

    function _updateLtv(address reserve,uint256 ltv) internal onlyReserves(reservedData(reserve)) {
        reserved[reserve].baseLTV = ltv;
    }

    function _updateLiquidationThreshold(address reserve,uint256 lt) internal onlyReserves(reservedData(reserve)) {
        reserved[reserve].liquidationThreshold = lt;
    }    

    function _updateLendingInterest(address reserve,uint256 interest) internal onlyReserves(reservedData(reserve)) {
        reserved[reserve].interestForReserve = interest;
    }  

    function _updateLendingPeriod(address reserve,uint256 period) internal onlyReserves(reservedData(reserve)) {
        reserved[reserve].interestPeriod = period;
    }   

    function _updateReserveSupply(address reserve, uint256 amount, uint operation) internal onlyReserves(reservedData(reserve)) {
        require(operation == 0 || operation == 1,"operation must be zero or one");
        ReservedData storage reserves = reserved[reserve];
        reserves.supplyInReserve = (operation == 0) ? (reserves.supplyInReserve + amount) : (reserves.supplyInReserve - amount);
    }

    function _updateBorrow(address reserve, address caller, uint256 amount, uint operation) internal onlyReserves(reservedData(reserve)) onlyAuthorizedBorrows(caller) {
        require(operation == 0 || operation == 1,"operation must be zero or one");
        ReservedData storage reserves = reserved[reserve];
        if(operation == 0) { 
            _updateReserveSupply(
                reserve,
                amount,
                1
            );
            reserves.borrowTotal += amount;
        } else {
            _updateReserveSupply(
                reserve,
                amount,
                0
            );
            reserves.borrowTotal -= amount;
        }
    }

    function _availableReserve(address reserve) internal view returns (uint available) {
        ReservedData memory reserves = reserved[reserve];
        available = reserves.supplyInReserve - reserves.borrowTotal;
    }

    function reservedData(address reserve) public view returns (ReservedData memory reserveData) {
        return reserved[reserve];
    }

    function allReservedTokens() public view returns (address[] memory reserves) {
        return reservedInfo.reserve;
    }

    function getIndexByReserve(address reserve) public view returns (uint index) {
        return reservedInfo.position[reserve];
    }

    function getReserveByIndex(uint index) public view returns (address reserve) {
        return reservedInfo.reserve[index];
    }
}

contract LendingConfigurator is LendingStorage {
    address configurator;
    uint diviser = 10000;

    constructor() {
        configurator = msg.sender;
    }

    modifier onlyConfigurator() {
        require(configurator == msg.sender,"Only configurator");
        _;
    }

    function setConfigurator(address configAddress) external onlyConfigurator {
        require(configAddress != address(0),"configAddress must not be a zero address");
        configurator = configAddress;
    }

    function configureReserve(address reserve, uint256 liquidationThreshold, uint256 ltv, uint256 interest, uint256 lendingPeriod) external onlyConfigurator {
        require(liquidationThreshold != 0,"liquidationThreshold != 0");
        require(ltv != 0,"ltv != 0");
        require(ltv <= diviser,"ltv must not exceed 10000");
        _configureReserve(
            reserve,
            liquidationThreshold,
            ltv,
            interest,
            lendingPeriod
        );
    }

    function updateLtv(address reserve,uint256 ltv) external onlyConfigurator {
        require(ltv != 0,"ltv != 0");
        require(ltv <= diviser,"ltv must not exceed 10000");
        _updateLtv(reserve, ltv);
    }

    function updateLiquidationThreshold(address reserve,uint256 lt) external onlyConfigurator {
        require(lt != 0,"lt != 0");
        _updateLiquidationThreshold(reserve, lt);
    }  

    function updateLendingInterest(address reserve,uint256 interest) external onlyConfigurator {
        require(interest > 0,"interest > 0");
        _updateLendingInterest(reserve,interest);
    }  

    function updateLendingPeriod(address reserve,uint256 period) external onlyConfigurator {
        require(period > 0,"period > 0");
        _updateLendingPeriod(reserve,period);
    }     
}

contract lenderDataProvider is LendingConfigurator {
    struct LenderReserve {
        uint supplied;
        uint totalClaimedInterest;
        uint lastInterestClaimed;
    }

    mapping(address => mapping(address => LenderReserve)) public lenderReserve;

    function _deposit(address reserve, address lender, uint256 amount) internal onlyReserves(reservedData(reserve)) {
        if(lenderReserve[lender][reserve].lastInterestClaimed == 0) {
            lenderReserve[lender][reserve].lastInterestClaimed = block.timestamp;
        }

        IERC20(reserve).transferFrom(
            lender,
            address(this),
            amount
        );
        
        lenderReserve[lender][reserve].supplied += amount;
        _updateReserveSupply(reserve, amount, 0);
    }

    function _withdraw(address reserve, address lender, uint256 amount) internal onlyReserves(reservedData(reserve)) {
        require(lenderReserve[lender][reserve].supplied >= amount,"amount exceed supply");
        lenderReserve[lender][reserve].supplied -= amount;
        _updateReserveSupply(reserve, amount, 1);

        IERC20(reserve).transfer(lender,amount);
        
        if(lenderReserve[lender][reserve].supplied == 0) {
            lenderReserve[lender][reserve].lastInterestClaimed = 0;
        }
    }

    function _claimInterest(address reserve, address lender) internal onlyReserves(reservedData(reserve)) {
        (uint interest, uint timestamp) = _calculateLenderInterest(reserve,msg.sender);
        lenderReserve[lender][reserve].totalClaimedInterest += interest;
        lenderReserve[lender][reserve].lastInterestClaimed += timestamp;
        IERC20(reserve).transfer(lender,interest);
    }

    function _calculateLenderInterest(address reserve, address lender) internal view returns (uint interest, uint timestamp) {
       ReservedData memory reservedData = reservedData(reserve);
       (interest,timestamp) = _interestCalculator(reserve,lender);
       timestamp = (reservedData.interestPeriod * timestamp);
    }

    function _interestCalculator(address reserve, address lender) internal view returns (uint interestAmt, uint interestCount) {
        LenderReserve storage lenderInfo = lenderReserve[lender][reserve];
        ReservedData memory reservedData = reservedData(reserve);
        uint interestCalculated = (lenderInfo.supplied * reservedData.interestForReserve) / diviser;
        interestCount = (block.timestamp - lenderInfo.lastInterestClaimed) / reservedData.interestPeriod;
        interestAmt = interestCalculated * interestCount;
    }
}

contract lenderInterestCalculator is lenderDataProvider {
    function calculateLenderInterest(address reserve, address lender) public view returns (uint interest, uint timestamp) {
       return _calculateLenderInterest(reserve, lender);
    }

    function claimInterest(address reserve) public {
        _claimInterest(reserve,msg.sender);
    }
}

contract lendingPool is lenderInterestCalculator {

    function deposit(address reserve, uint256 amount) external {
        require(amount > 0,"amount > 0");
        _deposit(reserve, msg.sender, amount);
    }

    function withdraw(address reserve, uint256 amount) external {
        require(amount > 0,"amount > 0");
        require(_availableReserve(reserve) >= amount,"insufficient fund");
        _claimInterest(reserve,msg.sender);
        _withdraw(reserve, msg.sender, amount);
        
    }

    function updateBorrow(address reserve, uint amount, uint operation) external {
        _updateBorrow(reserve, msg.sender, amount, operation);
    }

    function availableReserves(address reserve) external view returns (uint available) {
        return _availableReserve(reserve);
    }
}