// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IFeesController.sol";
import "./interfaces/IVaultController.sol";

contract FeedLoan is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    Counters.Counter private _tokenIds;

    /***********************
     ** Structs and Enums **
     ***********************/

    enum LoanStatus {
        Active,
        Repaid,
        Liquidated,
        Completed
    }

    struct Loan {
        LoanStatus status;
        address collateral; // Collateral asset
        uint256 collateralAmount; // Amount of collateral asset put down by borrower
        address asset;
        uint256 assetAmount;
        uint256 startTime;
        uint256 duration;
        uint256 intRateBP;
        bool intProRated;
        uint256 maxRepayment;
        uint256 earnedInterest;
        bool allowLiquidator;
    }

    struct VaultInfo {
        bool useVault;
        uint256 vid;
    }

    /***************
     ** Variables **
     ***************/

    /// @dev Fees cap
    uint256 public constant MAXIMUM_LENDER_FEE_BP = 1000;
    uint256 public constant MAXIMUM_BORROWER_FEE_BP = 1000;

    /// @dev An autoincrement number which represent an Unique ID for each individual loan
    uint256 public totalLoansCount;

    /// @dev A counter for total active loans
    uint256 public totalActiveLoans;

    /// @dev An address of DealManager
    address public dealManager;

    /// @dev An address of FeesController
    address public feesController;

    /// @dev An address of VaultController
    address public vaultController;

    /// @dev A lender's fees basis point
    uint256 public lenderFeeBP = 15;

    /// @dev Lender's fees collector address
    address public lenderFeeCollector;

    /// @dev A borrower's fees basis point
    uint256 public borrowerFeeBP = 15;

    /// @dev Borrower's fees collector address
    address public borrowerFeeCollector;

    /*************
     ** Mapping **
     *************/

    /// @dev Mapping loan's ID to loan
    mapping(uint256 => Loan) public loans;

    /// @dev Mapping loan's ID to lender address
    mapping(uint256 => address) public loanLender;

    /// @dev Mapping loan's ID to borrower address
    mapping(uint256 => address) public loanBorrower;

    /// @dev Mapping loan's ID to VaultInfo
    mapping(uint256 => VaultInfo) public loanVault;

    /// @dev Mapping lender address to loan's ID
    mapping(address => uint256[]) public lenderLoans;

    /// @dev Mapping borrower address to loan's ID
    mapping(address => uint256[]) public borrowerLoans;

    /*************
     ** Events **
     *************/

    event LoanStarted(
        uint256 indexed _id,
        address indexed _lender,
        address _asset,
        uint256 _assetAmount,
        address indexed _borrower,
        address _collateral,
        uint256 _collateralAmount,
        uint256 _duration,
        uint256 _intRateBP,
        bool _intProRated,
        bool _useVault,
        uint256 _vaultId
    );
    event LoanAllowLiquidatorChanged(uint256 indexed _loanId, bool _allowLiquidator);
    event LoanRepaid(
        uint256 indexed _loanId,
        uint256 _repaymentAmount,
        uint256 _earnedInterest,
        uint256 _lenderFee,
        uint256 _borrowerFee
    );
    event LoanLiquidated(uint256 indexed _loanId, uint256 _returnAmount, uint256 _lenderFee, uint256 _borrowerFee);
    event LoanLiquidatedOnBehalf(
        uint256 indexed _loanId,
        address indexed _liquidator,
        uint256 _returnAmount,
        uint256 _repaymentAmount,
        uint256 _earnedInterest,
        uint256 _lenderFee,
        uint256 _borrowerFee
    );
    event LoanRedeemed(uint256 _loanId);

    event LenderFeeBPChanged(uint256 _lenderFeeBP);
    event BorrowerFeeBPChanged(uint256 _borrowerFeeBP);
    event LenderFeeCollectorChanged(address _lenderFeeCollector);
    event BorrowerFeeCollectorChanged(address _borrowerFeeCollector);
    event VaultControllerChanged(address _vaultController);

    /***************
     ** Modifiers **
     ***************/

    /**
     * @notice Function modifier to check whether send is deal manager
     */
    modifier onlyDealManager() {
        require(msg.sender == dealManager, "Forbidden: only deal manager is allowed");
        _;
    }

    /************************
     ** Internal Functions **
     ************************/

    /**
     * @notice Override beforeTokenTransfer function
     * @param from: sender's address
     * @param to: receiver's address
     * @param tokenId: token'id to transfer
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (to != address(0)) {
            loanLender[tokenId] = to;
        }
    }

    /**
     * @notice Calculate loan maximum repayment
     * @param _loanPrincipalAmount: Loan principal
     * @param _loanDuration: Loan duration in seconds
     * @param _loanIntRateBP: Loan interest rate in basis points
     * @return uint256: maximum repayment amount
     */
    function _calcMaximumRepayment(
        uint256 _loanPrincipalAmount,
        uint256 _loanDuration,
        uint256 _loanIntRateBP
    ) internal pure returns (uint256) {
        return _loanPrincipalAmount.mul(_loanIntRateBP).mul(_loanDuration).div(10000).div(31536000).add(_loanPrincipalAmount);
    }

    /**
     * @notice Calculate loan interest rate due
     * @param _loanPrincipalAmount: Loan principal
     * @param _loanIntRateBP: Loan interest rate in basis points
     * @param _loanDuration: Loan duration in seconds
     * @param _loanDurationElapsed: Loan elapsed duration in seconds
     * @param _loanIntProRated: Loan prorated setting
     * @return uint256: interest rate due
     */
    function _calcInterestDue(
        uint256 _loanPrincipalAmount,
        uint256 _loanIntRateBP,
        uint256 _loanDuration,
        uint256 _loanDurationElapsed,
        bool _loanIntProRated
    ) internal pure returns (uint256) {
        uint256 _interestDue = _loanPrincipalAmount.mul(_loanIntRateBP).mul(_loanDuration).div(10000).div(31536000);
        uint256 _interestAccured = _interestDue.mul(_loanDurationElapsed).div(_loanDuration);
        // If loan is prorated
        if (_loanIntProRated) return _interestAccured;

        // if loan is not prorated
        uint256 _maximumInterest = _calcMaximumRepayment(_loanPrincipalAmount, _loanDuration, _loanIntRateBP);
        if (_loanPrincipalAmount.add(_interestAccured) > _maximumInterest) {
            return _maximumInterest.sub(_loanPrincipalAmount);
        } else {
            return _interestAccured;
        }
    }

    /***************
     ** Functions **
     ***************/

    /**
     * @notice Constructor
     * @param tokenName: Name of Token
     * @param symbol: Symbol of Token
     * @param _dealManager: An address of DealManager
     * @param _feesController: An address of FeesController
     * @param _lenderFeeCollector: An address of lender's fee collector
     * @param _borrowerFeeCollector: An address of borrower's fee collector
     */
    constructor(
        string memory tokenName,
        string memory symbol,
        address _dealManager,
        address _feesController,
        address _lenderFeeCollector,
        address _borrowerFeeCollector
    ) ERC721(tokenName, symbol) {
        dealManager = _dealManager;
        feesController = _feesController;
        lenderFeeCollector = _lenderFeeCollector;
        borrowerFeeCollector = _borrowerFeeCollector;
    }

    /**
     * @dev Transfer and check for deflationary effects
     * @param _from: sender's address
     * @param _to: receiver's address
     * @param _token: token contract address
     * @param _amount: amount of token to transfer
     * @return uint256 number of token transfer
     */
    function _safeDeflationaryTransfer(
        address _from,
        address _to,
        address _token,
        uint256 _amount
    ) internal returns (uint256) {
        uint256 _before = IERC20(_token).balanceOf(address(_to));
        IERC20(_token).safeTransferFrom(address(_from), address(_to), _amount);
        return IERC20(_token).balanceOf(address(_to)).sub(_before);
    }

    /**
     * @notice Start Loan
     * @param _lender: An address of lender
     * @param _asset: An address of asset to lend
     * @param _assetAmount: Amount of asset to lend
     * @param _borrower: An address of borrower
     * @param _collateral: An address of collateral
     * @param _collateralAmount: Amount of colleteral to collateralize
     * @param _duration: A duration of loan in seconds
     * @param _intRateBP: Loan's interest rate in basis points
     * @param _intProRated: Loan's prorated setting
     * @param _useVault: Deposit loan's collateral to Vault
     * @param _vaultId: Vault ID to deposit
     * @return uint256 Loan ID
     */
    function startLoan(
        address _lender,
        address _asset,
        uint256 _assetAmount,
        address _borrower,
        address _collateral,
        uint256 _collateralAmount,
        uint256 _duration,
        uint256 _intRateBP,
        bool _intProRated,
        bool _useVault,
        uint256 _vaultId
    ) external onlyDealManager returns (uint256) {
        // Transfer collateral from DealManager to this contract
        _collateralAmount = _safeDeflationaryTransfer(msg.sender, address(this), _collateral, _collateralAmount);

        // Transfer lending asset to borrower
        _assetAmount = _safeDeflationaryTransfer(msg.sender, _borrower, _asset, _assetAmount);

        // Increment token's ID which use for loan ID
        _tokenIds.increment();
        uint256 _id = _tokenIds.current();

        // Interest rate basis points must be greater than zero
        require(_intRateBP > 0, "StartLoan: Interest rate is negative");

        // Duration msut be greater than zero
        require(_duration > 0, "StartLoan: Duration is zero");

        // If Loan use Vault to monetize on collateral
        if (_useVault) {
            // Store loan's vault info
            loanVault[_id] = VaultInfo({useVault: _useVault, vid: _vaultId});

            uint256 _beforeVaultBalance = IVaultController(vaultController).balance(_vaultId, _id);

            // Approve and deposit collateral to Vault through VaultController
            IERC20(_collateral).safeApprove(address(vaultController), 0);
            IERC20(_collateral).safeApprove(address(vaultController), _collateralAmount);
            IVaultController(vaultController).deposit(_vaultId, _id, _collateralAmount);

            _collateralAmount = IVaultController(vaultController).balance(_vaultId, _id).sub(_beforeVaultBalance);
        }

        // Save Loan to storage and increment total loans count
        loans[_id] = Loan({
            status: LoanStatus.Active,
            collateral: _collateral,
            collateralAmount: _collateralAmount,
            asset: _asset,
            assetAmount: _assetAmount,
            startTime: block.timestamp,
            duration: _duration,
            intRateBP: _intRateBP,
            intProRated: _intProRated,
            maxRepayment: _calcMaximumRepayment(_assetAmount, _duration, _intRateBP),
            earnedInterest: 0,
            allowLiquidator: false
        });

        loanLender[_id] = _lender;
        loanBorrower[_id] = _borrower;
        totalLoansCount += 1;
        totalActiveLoans += 1;
        lenderLoans[_lender].push(_id);
        borrowerLoans[_borrower].push(_id);

        // Mint NFT to lender
        _safeMint(_lender, _id);

        // Emit LoanStarted event
        emit LoanStarted(
            _id,
            _lender,
            _asset,
            _assetAmount,
            _borrower,
            _collateral,
            _collateralAmount,
            _duration,
            _intRateBP,
            _intProRated,
            _useVault,
            _vaultId
        );

        // Return Loan's ID
        return _id;
    }

    /**
     * @notice Set Loan's to allow or disallow liquidator
     * @param _loanId: Loan's ID
     * @param _allowLiquidator: Allow or disallow liquidator
     */
    function setAllowLiquidator(uint256 _loanId, bool _allowLiquidator) external onlyDealManager {
        Loan storage _loan = loans[_loanId];

        _loan.allowLiquidator = _allowLiquidator;

        emit LoanAllowLiquidatorChanged(_loanId, _allowLiquidator);
    }

    /**
     * @notice Borrower make payback loan with borrowed asset
     * @param _loanId: Loan's ID
     */
    function payback(uint256 _loanId) external nonReentrant {
        // Verify sender is borrower
        require(msg.sender == loanBorrower[_loanId], "Payback: Sender is not borrower");

        // Fetch loan details from storage
        Loan storage _loan = loans[_loanId];

        // Verify loan is only in Active status
        require(_loan.status == LoanStatus.Active, "Payback: Loan is not active");

        // Get loan interest due
        uint256 _interestDue = _loan.maxRepayment.sub(_loan.assetAmount);

        // If loan is prorated
        if (_loan.intProRated) {
            // Calculate interest due until current block
            _interestDue = _calcInterestDue(
                _loan.assetAmount,
                _loan.intRateBP,
                _loan.duration,
                block.timestamp.sub(_loan.startTime),
                _loan.intProRated
            );
        }

        // Get lender's fee
        uint256 _lenderFee = _interestDue.mul(lenderFeeBP).div(10000);

        // Get borrower's fee
        uint256 _borrowerFee = _interestDue.mul(borrowerFeeBP).div(10000);

        // If fees controller is set, adjust lender and borrower fees accordingly
        if (feesController != address(0)) {
            // Calculate and set lender & borrower fee by using discount basis point from FeesController
            _lenderFee = _lenderFee.sub(_lenderFee.mul(IFeesController(feesController).getDiscountBP(loanLender[_loanId])).div(10000));
            _borrowerFee = _borrowerFee.sub(
                _borrowerFee.mul(IFeesController(feesController).getDiscountBP(loanBorrower[_loanId])).div(10000)
            );
        }

        // Calculate total repayment amount
        uint256 _repaymentAmount = _loan.assetAmount.add(_interestDue).sub(_lenderFee.add(_borrowerFee));

        // Transfer principal including interest from borrower to contract
        uint256 _assetAmount = _safeDeflationaryTransfer(loanBorrower[_loanId], address(this), _loan.asset, _repaymentAmount);

        // Update loan asset amount in case token is deflationary
        _loan.assetAmount = _assetAmount.sub(_interestDue.sub(_lenderFee.add(_borrowerFee)));

        // Transfer lender's fee
        IERC20(_loan.asset).safeTransferFrom(loanBorrower[_loanId], address(lenderFeeCollector), _lenderFee);

        // Transfer borrower's fee
        IERC20(_loan.asset).safeTransferFrom(loanBorrower[_loanId], address(borrowerFeeCollector), _borrowerFee);

        // Set loan as repaid
        _loan.status = LoanStatus.Repaid;

        // Update loan asset amount
        _loan.earnedInterest = _interestDue.sub(_lenderFee.add(_borrowerFee));

        // Update total number of active loans
        totalActiveLoans -= 1;

        // If collateral is in vault
        if (loanVault[_loanId].useVault) {
            uint256 _withdrawnAmount = _withdrawFromVault(_loanId);
            // Transfer collateral to borrower
            IERC20(_loan.collateral).safeTransfer(loanBorrower[_loanId], _withdrawnAmount);
        } else {
            // Transfer collateral to borrower
            IERC20(_loan.collateral).safeTransfer(loanBorrower[_loanId], _loan.collateralAmount);
        }

        // Emit LoanRepaid event
        emit LoanRepaid(_loanId, _repaymentAmount, _loan.earnedInterest, _lenderFee, _borrowerFee);
    }

    // Lender liquidate overdue loan
    function liquidateOnBehalf(uint256 _loanId) external nonReentrant {
        // Fetch loan from storage
        Loan storage _loan = loans[_loanId];

        // Check whether lender allow liquidator to liquidate loan
        require(_loan.allowLiquidator, "FeedLoan(liquidateOnBehalf): Liquidator is not allowed");

        // Loan should not be repaid, liquidated or completed
        require(_loan.status == LoanStatus.Active, "FeedLoan(liquidateOnBehalf): Loan is not active");

        // Current block time is greater than loan starting time plus duration
        require(block.timestamp > _loan.startTime.add(_loan.duration), "FeedLoan(liquidateOnBehalf): Loan is not overdue");

        uint256 _interestDue = _loan.maxRepayment.sub(_loan.assetAmount);
        if (_loan.intProRated) {
            _interestDue = _calcInterestDue(
                _loan.assetAmount,
                _loan.intRateBP,
                _loan.duration,
                block.timestamp.sub(_loan.startTime),
                _loan.intProRated
            );
        }

        uint256 _lenderFee = _interestDue.mul(lenderFeeBP).div(10000);
        uint256 _borrowerFee = _interestDue.mul(borrowerFeeBP).div(10000);

        // If fees controller is set, adjust lender and borrower fees accordingly
        if (feesController != address(0)) {
            // Calculate and set lender & borrower fee by using discount basis point from FeesController
            _lenderFee = _lenderFee.sub(_lenderFee.mul(IFeesController(feesController).getDiscountBP(loanLender[_loanId])).div(10000));
            _borrowerFee = _borrowerFee.sub(
                _borrowerFee.mul(IFeesController(feesController).getDiscountBP(loanBorrower[_loanId])).div(10000)
            );
        }

        uint256 _repaymentAmount = _loan.assetAmount.add(_interestDue).sub(_lenderFee.add(_borrowerFee));

        // Transfer principal including interest from liquidator to contract
        uint256 _assetAmount = _safeDeflationaryTransfer(address(msg.sender), address(this), _loan.asset, _repaymentAmount);

        // Update loan asset amount in case token is deflationary
        _loan.assetAmount = _assetAmount.sub(_interestDue.sub(_lenderFee.add(_borrowerFee)));

        // Transfer lender's fee
        IERC20(_loan.asset).safeTransferFrom(address(msg.sender), address(lenderFeeCollector), _lenderFee);

        // Transfer borrower's fee
        IERC20(_loan.asset).safeTransferFrom(address(msg.sender), address(borrowerFeeCollector), _borrowerFee);

        // Set loan status
        _loan.status = LoanStatus.Repaid;

        // Update loan asset amount
        _loan.earnedInterest = _interestDue.sub(_lenderFee.add(_borrowerFee));

        // Update total number of active loans
        totalActiveLoans -= 1;

        uint256 _returnAmount = 0;
        // If collateral is in vault
        if (loanVault[_loanId].useVault) {
            _returnAmount = _withdrawFromVault(_loanId);
        } else {
            _returnAmount = _loan.collateralAmount;
        }

        // Tranfer collateral to liquidator
        IERC20(_loan.collateral).safeTransfer(address(msg.sender), _returnAmount);

        // Emit LoanLiquidatedOnBehalf event
        emit LoanLiquidatedOnBehalf(
            _loanId,
            address(msg.sender),
            _returnAmount,
            _repaymentAmount,
            _loan.earnedInterest,
            _lenderFee,
            _borrowerFee
        );
    }

    // Lender liquidate overdue loan
    function liquidate(uint256 _loanId) external nonReentrant {
        // Fetch loan from storage
        Loan storage _loan = loans[_loanId];

        // Loan should not be repaid, liquidated or completed
        require(_loan.status == LoanStatus.Active, "FeedLoan(liquidate): Loan is not active");

        // Current block time is greater than loan starting time plus duration
        require(block.timestamp > _loan.startTime.add(_loan.duration), "FeedLoan(liquidate): Loan is not overdue");

        // Get loan's lender
        address _lender = loanLender[_loanId];

        // Only lender is allowed to liquidate the loan
        require(_lender == msg.sender, "FeedLoan(liquidate): Sender is not lender");

        // Burn NFT
        _burn(_loanId);

        // Set loan status
        _loan.status = LoanStatus.Liquidated;

        // Update total number of active loans
        totalActiveLoans -= 1;

        uint256 _returnAmount = 0;
        // If collateral is in vault
        if (loanVault[_loanId].useVault) {
            // Collateral balance AFTER withdraw
            _returnAmount = _withdrawFromVault(_loanId);
        } else {
            _returnAmount = _loan.collateralAmount;
        }

        uint256 _lenderFee = _returnAmount.mul(lenderFeeBP).div(10000);
        uint256 _borrowerFee = _returnAmount.mul(borrowerFeeBP).div(10000);

        // If fees controller is set, adjust lender and borrower fees accordingly
        if (feesController != address(0)) {
            // Calculate and set lender & borrower fee by using discount basis point from FeesController
            _lenderFee = _lenderFee.sub(_lenderFee.mul(IFeesController(feesController).getDiscountBP(loanLender[_loanId])).div(10000));
            _borrowerFee = _borrowerFee.sub(
                _borrowerFee.mul(IFeesController(feesController).getDiscountBP(loanBorrower[_loanId])).div(10000)
            );
        }

        // Transfer lender's fee
        IERC20(_loan.collateral).safeTransfer(lenderFeeCollector, _lenderFee);

        // Transfer borrower's fee
        IERC20(_loan.collateral).safeTransfer(borrowerFeeCollector, _borrowerFee);

        // Calculate amount of collateral to return to lender after fees
        _returnAmount = _returnAmount.sub(_lenderFee).sub(_borrowerFee);

        // Tranfer collateral to lender
        IERC20(_loan.collateral).safeTransfer(_lender, _returnAmount);

        // Emit LoanLiquidated event
        emit LoanLiquidated(_loanId, _returnAmount, _lenderFee, _borrowerFee);
    }

    // Lender redeem repaid loan
    function redeem(uint256 _loanId) external nonReentrant {
        Loan storage _loan = loans[_loanId];
        require(_loan.status == LoanStatus.Repaid, "FeedLoan(redeem): Loan is not repaid");

        require(ownerOf(_loanId) == address(msg.sender), "FeedLoan(redeem): Sender is not owner");
        require(loanLender[_loanId] == address(msg.sender), "FeedLoan(redeem): Sender is not lender");

        // Burn NFT
        _burn(_loanId);

        // Set loan's status to completed
        _loan.status = LoanStatus.Completed;

        // Transfer asset to lender
        IERC20(_loan.asset).safeTransfer(loanLender[_loanId], _loan.assetAmount.add(_loan.earnedInterest));

        // Emit LoanRedeemed event
        emit LoanRedeemed(_loanId);
    }

    /**
     * @dev Withdraw collateral from vault
     * @param _loanId: Loan ID
     * @return uint256: amount of collateral withdrawn from vault
     */
    function _withdrawFromVault(uint256 _loanId) internal returns (uint256) {
        Loan storage _loan = loans[_loanId];
        uint256 _before = IERC20(_loan.collateral).balanceOf(address(this));
        IVaultController(vaultController).withdraw(loanVault[_loanId].vid, _loanId);
        uint256 _after = IERC20(_loan.collateral).balanceOf(address(this));

        // Update collateral amount
        _loan.collateralAmount = _after.sub(_before);

        return _loan.collateralAmount;
    }

    /********************
     ** View Functions **
     ********************/

    /**
     * @notice Get interest rate due to current block by loan's ID
     * @param _loanId: Loan ID
     * @return uint256: interest rate due
     */
    function interestDue(uint256 _loanId) public view returns (uint256) {
        Loan memory _loan = loans[_loanId];
        return
            _calcInterestDue(
                _loan.assetAmount,
                _loan.intRateBP,
                _loan.duration,
                block.timestamp.sub(_loan.startTime),
                _loan.intProRated
            );
    }

    /**
     * @notice Get balance of collateral in target vault
     * @param _loanId: Loan ID
     * @return uint256: Balance of collateral
     */
    function vaultBalance(uint256 _loanId) public view returns (uint256) {
        return IVaultController(vaultController).balance(loanVault[_loanId].vid, _loanId);
    }

    /**
     * @notice Get total number of loans for specific lender
     * @param _lender: Loan's lender address
     * @return uint256: Total number of loans
     */
    function lenderLoansCount(address _lender) public view returns (uint256) {
        return lenderLoans[_lender].length;
    }

    /**
     * @notice Get total number of loans for specific borrower
     * @param _borrower: Loan's lender address
     * @return uint256: Total number of loans
     */
    function borrowerLoansCount(address _borrower) public view returns (uint256) {
        return borrowerLoans[_borrower].length;
    }

    /**
     * @notice View list of loans
     * @param _cursor: cursor
     * @param _size: size
     */
    function viewLoans(uint256 _cursor, uint256 _size) public view returns (Loan[] memory, uint256) {
        uint256 _length = _size;
        uint256 _offersLength = totalLoansCount;
        if (_length > _offersLength - _cursor) {
            _length = _offersLength - _cursor;
        }

        Loan[] memory _values = new Loan[](_length);
        for (uint256 i = 0; i < _length; i++) {
            _values[i] = loans[_cursor + i + 1];
        }

        return (_values, _cursor + _length);
    }

    /**
     * @notice View list of loans by lender
     * @param _lender: lender address
     * @param _cursor: cursor
     * @param _size: size
     */
    function viewLoansPerLender(
        address _lender,
        uint256 _cursor,
        uint256 _size
    ) external view returns (Loan[] memory, uint256) {
        uint256 _length = _size;
        uint256 _bidsLength = lenderLoans[_lender].length;
        if (_length > _bidsLength - _cursor) {
            _length = _bidsLength - _cursor;
        }

        Loan[] memory _values = new Loan[](_length);
        for (uint256 i = 0; i < _length; i++) {
            uint256 _loanId = lenderLoans[_lender][_cursor + i];
            _values[i] = loans[_loanId];
        }

        return (_values, _cursor + _length);
    }

    /**
     * @notice View list of loans by borrower
     * @param _borrower: borrower address
     * @param _cursor: cursor
     * @param _size: size
     */
    function viewLoansPerBorrower(
        address _borrower,
        uint256 _cursor,
        uint256 _size
    ) external view returns (Loan[] memory, uint256) {
        uint256 _length = _size;
        uint256 _bidsLength = borrowerLoans[_borrower].length;
        if (_length > _bidsLength - _cursor) {
            _length = _bidsLength - _cursor;
        }

        Loan[] memory _values = new Loan[](_length);
        for (uint256 i = 0; i < _length; i++) {
            uint256 _loanId = borrowerLoans[_borrower][_cursor + i];
            _values[i] = loans[_loanId];
        }

        return (_values, _cursor + _length);
    }

    /*********************
     ** Admin Functions **
     *********************/

    /**
     * @notice Set Lender's fee basis point
     * @param _lenderFeeBP: lender's fee in basis point
     * @dev Callable by owner
     */
    function setLenderFeeBP(uint256 _lenderFeeBP) external onlyOwner nonReentrant {
        require(_lenderFeeBP <= MAXIMUM_LENDER_FEE_BP, "SetLenderFeeBP: must lesser than or equal to threshold");
        require(_lenderFeeBP >= 0, "SetLenderFeeBP: must greater than or equal to zero");

        lenderFeeBP = _lenderFeeBP;

        emit LenderFeeBPChanged(lenderFeeBP);
    }

    /**
     * @notice Set Borrower's fee basis point
     * @param _borrowerFeeBP: borrower's fee in basis point
     * @dev Callable by owner
     */
    function setBorrowerFeeBP(uint256 _borrowerFeeBP) external onlyOwner nonReentrant {
        require(_borrowerFeeBP <= MAXIMUM_BORROWER_FEE_BP, "SetBorrowerFeeBP: must lesser than or equal to threshold");
        require(_borrowerFeeBP >= 0, "SetBorrowerFeeBP: must greater than or equal to zero");

        borrowerFeeBP = _borrowerFeeBP;

        emit BorrowerFeeBPChanged(borrowerFeeBP);
    }

    /**
     * @notice Set Lender's fee collector
     * @param _lenderFeeCollector: lender's fee collector address
     * @dev Callable by owner
     */
    function setLenderFeeCollector(address _lenderFeeCollector) external onlyOwner nonReentrant {
        require(_lenderFeeCollector != address(0), "SetLenderFeeCollector: Cannot be zero address");

        lenderFeeCollector = _lenderFeeCollector;

        emit LenderFeeCollectorChanged(lenderFeeCollector);
    }

    /**
     * @notice Set Borrower's fee collector
     * @param _borrowerFeeCollector: borrower's fee collector address
     * @dev Callable by owner
     */
    function setBorrowerFeeCollector(address _borrowerFeeCollector) external onlyOwner nonReentrant {
        require(_borrowerFeeCollector != address(0), "SetBorrowerFeeCollector: Cannot be zero address");

        borrowerFeeCollector = _borrowerFeeCollector;

        emit BorrowerFeeCollectorChanged(borrowerFeeCollector);
    }

    /**
     * @notice Set VaultController address
     * @param _vaultController: address of new VaultController
     * @dev Callable by owner
     */
    function setVaultController(address _vaultController) external onlyOwner nonReentrant {
        require(_vaultController != address(0), "SetVaultController: Cannot be zero address");
        require(vaultController == address(0), "SetVaultController: Cannot replace vault controller");

        vaultController = _vaultController;

        emit VaultControllerChanged(_vaultController);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
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
     * by making the `nonReentrant` function external, and make it call a
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IFeesController {
    function getDiscountBP(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IVaultController {
    function deposit(
        uint256 _vid,
        uint256 _loanId,
        uint256 _amount
    ) external;

    function withdraw(uint256 _vid, uint256 _loanId) external;

    function vaultInfo(uint256 _vid) external view returns (address, address);

    function vaultLength() external view returns (uint256);

    function balance(uint256 _vid, uint256 _loanId) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}