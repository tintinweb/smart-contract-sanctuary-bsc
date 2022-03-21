// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./math/ErrorReporter.sol";
import "./math/Exponential.sol";
import "./VaultLib.sol";
import "./GildToken.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IVenusBNB.sol";
import "./interfaces/IVenusToken.sol";

contract Vault is ReentrancyGuard, Exponential, TokenErrorReporter {
    using SafeMath for uint256;

    uint256 public constant MAX_BORROW = 7700; // 77%
    uint256 public constant REPAY_FEE = 10; // 0.1%
    uint256 public constant PLATFORM_LIQUIDATE_BPS = 200; // 2%
    uint256 public constant LIQUIDATE_BPS = 300; // 3%
    uint256 public constant OPEN_POSITION_FEE = 0.001 ether;
    uint256 public appID;
    uint256 public borrowID;
    uint256 public totalDevFund;
    address public dev;
    address public router;
    address public profitShare;
    address public wbnb;
    GildToken public gildToken;

    struct LoanApplication {
        uint256 id;
        address owner;
        address loanToken;
        uint256 loanAmount;
        address[] availableCollateralTokens;
        uint256[] interestRates;
        uint256[] durations;
        bool open;
        address vToken;
        uint256 vTokenAmount;
    }

    struct Borrow {
        uint256 appID;
        address owner;
        address collateralToken;
        uint256 collateralAmount;
        address[] collateralPricePath;
        uint256 borrowAmount;
        uint256 startBlock;
        uint256 interestRate;
        uint256 duration;
        uint256 dueDateBlock;
        uint256 lastPayBlock;
        uint8 status; //1=open, 2=close repay all, 3=close due to liquiated
        address vToken;
        uint256 vTokenAmount;
    }

    // appID => LoanApplication
    mapping(uint256 => LoanApplication) public loanApplications;

    // owner => LoanApplication []
    mapping(address => LoanApplication[]) public myLoanApplications;
    // owner => loan token => id
    mapping(address => mapping(address => uint256)) public existingLoan;

    //appID => collateralToken => path[]
    mapping(uint256 => mapping(address => address[]))
        public loanCollateralPricePaths;

    // borrowID = > Loan
    mapping(uint256 => Borrow) public borrows;

    // borrower address
    mapping(address => Borrow[]) public myBorrows;

    event CreateLoanApp(uint256 loanID);
    event UpdateLoanApp();
    event EnableOrDisableLoanApp(uint256 loanID, bool status);
    event DepositLoan();
    event WithdrawLoan();
    event CreateBorrow(uint256 borrowID);
    event DepositCollateral();
    event WithdrawCollateral();
    event Repay(uint256 principal, uint256 interest, uint256 fee);
    event Liquidate(
        uint256 borrowID,
        uint256 swapCollateralAmount,
        uint256 swapAmountOut,
        uint256 swapExactAmountOut,
        uint256 toOwner,
        uint256 liquidatorPrize,
        uint256 devFee,
        uint256 profitShareFee
    );

    constructor(
        address _router,
        address _dev,
        GildToken _gildToken,
        address _profitShare,
        address _wbnb
    ) {
        router = _router;
        appID = 0;
        borrowID = 0;
        totalDevFund = 0;
        dev = _dev;
        gildToken = _gildToken;
        profitShare = _profitShare;
        wbnb = _wbnb;
    }

    function createLoanApp(
        address _loanToken,
        uint256 _loanAmount,
        address[] calldata _collateralTokens,
        address[][] calldata _pricePaths,
        uint256[] calldata _interestRates,
        uint256[] calldata _durations,
        address vToken
    ) public payable nonReentrant {
        if (_loanToken == address(0)) {
            require(_loanAmount == msg.value.sub(OPEN_POSITION_FEE), "r00");
        } else {
            require(msg.value == OPEN_POSITION_FEE, "r0");
        }

        require(existingLoan[msg.sender][_loanToken] == 0, "r1");
        require(_interestRates.length == _durations.length, "r2");
        require(_collateralTokens.length == _pricePaths.length, "r22");
        require(VaultLib.validCollateral(_loanToken, _collateralTokens), "r3");
        require(VaultLib.checkInterestRates(_interestRates), "r4");
        require(VaultLib.checkDurations(_durations), "r5");
        require(
            VaultLib.checkCollateralPath(
                _loanToken,
                _collateralTokens,
                _pricePaths,
                wbnb
            ),
            "r6"
        );

        if (_loanToken != address(0)) {
            IERC20(_loanToken).transferFrom(
                address(msg.sender),
                address(this),
                _loanAmount
            );
        }

        uint256 vTokenAmount = 0;
        if (vToken != address(0)) {
            vTokenAmount = mintVToken(vToken, _loanToken, _loanAmount);
        }

        appID++;
        LoanApplication memory app = LoanApplication(
            appID,
            msg.sender,
            _loanToken,
            _loanAmount,
            _collateralTokens,
            _interestRates,
            _durations,
            true,
            vToken,
            vTokenAmount
        );

        loanApplications[appID] = app;
        myLoanApplications[msg.sender].push(app);
        existingLoan[msg.sender][app.loanToken] = appID;

        for (uint256 i = 0; i < _collateralTokens.length; i++) {
            address a = _collateralTokens[i];
            loanCollateralPricePaths[appID][a] = _pricePaths[i];
        }

        uint256 profit = OPEN_POSITION_FEE;
        if (totalDevFund < 10000 ether) {
            uint256 fee = OPEN_POSITION_FEE / 2;
            payable(dev).transfer(fee);
            profit = OPEN_POSITION_FEE.sub(fee);
            totalDevFund.add(fee);
        }
        VaultLib.transferProfit(profitShare, address(0), profit);

        emit CreateLoanApp(appID);
    }

    function updateLoanApp(
        uint256 _id,
        address[] calldata _collateralTokens,
        address[][] calldata _pricePaths,
        uint256[] calldata _interestRates,
        uint256[] calldata _durations
    ) public {
        LoanApplication storage app = loanApplications[_id];
        require(app.id == _id, "r1");
        require(app.owner == msg.sender, "r2");
        require(_interestRates.length == _durations.length, "r3");
        require(_collateralTokens.length == _pricePaths.length, "r33");
        require(
            VaultLib.validCollateral(app.loanToken, _collateralTokens),
            "r333"
        );
        require(VaultLib.checkInterestRates(_interestRates), "r4");
        require(VaultLib.checkDurations(_durations), "r5");
        require(
            VaultLib.checkCollateralPath(
                app.loanToken,
                _collateralTokens,
                _pricePaths,
                wbnb
            ),
            "r6"
        );

        for (uint256 i = 0; i < _collateralTokens.length; i++) {
            address a = _collateralTokens[i];
            loanCollateralPricePaths[app.id][a] = _pricePaths[i];
        }
        app.availableCollateralTokens = _collateralTokens;
        app.interestRates = _interestRates;
        app.durations = _durations;

        LoanApplication[] memory myApps = myLoanApplications[msg.sender];
        uint256 length = myApps.length;
        uint256 index;
        for (uint256 i = 0; i < length; i++) {
            if (myApps[i].id == _id) {
                index = i;
                break;
            }
        }

        myLoanApplications[msg.sender][index] = app;
        emit UpdateLoanApp();
    }

    function enableOrDisableLoanApp(uint256 _id, bool status) public {
        LoanApplication storage app = loanApplications[_id];
        require(app.id == _id, "r1");
        require(app.owner == msg.sender, "r2");
        app.open = status;

        emit EnableOrDisableLoanApp(_id, status);
    }

    function getLoanApplications(address user)
        public
        view
        returns (LoanApplication[] memory myApps)
    {
        myApps = myLoanApplications[user];
        return myApps;
    }

    function getLoanCollateralPricePath(uint256 id, address loanToken)
        public
        view
        returns (address[] memory)
    {
        return loanCollateralPricePaths[id][loanToken];
    }

    function getBorrowCollateralPricePath(uint256 id)
        public
        view
        returns (address[] memory)
    {
        return borrows[id].collateralPricePath;
    }

    function depositLoan(
        uint256 _id,
        uint256 amount,
        address vToken
    ) public payable nonReentrant {
        LoanApplication storage app = loanApplications[_id];
        require(app.owner == msg.sender, "r1");

        if (app.loanToken == address(0)) {
            require(amount == msg.value, "r2");
        } else {
            IERC20(app.loanToken).transferFrom(
                address(msg.sender),
                address(this),
                amount
            );
        }
        if (app.vTokenAmount > 0) {
            app.loanAmount = redeemVToken(
                app.loanToken,
                app.vToken,
                app.vTokenAmount
            );
            app.vTokenAmount = 0;
        }
        app.loanAmount = app.loanAmount.add(amount);
        if (vToken != address(0)) {
            app.vTokenAmount = mintVToken(
                vToken,
                app.loanToken,
                app.loanAmount
            );
        }
        app.vToken = vToken;
        emit DepositLoan();
    }

    function withdrawLoan(
        uint256 _id,
        uint256 amount,
        address vToken
    ) public nonReentrant {
        LoanApplication storage app = loanApplications[_id];
        require(app.owner == msg.sender, "r0");
        require(app.loanAmount > 0, "r1");

        if (app.vTokenAmount > 0) {
            app.loanAmount = redeemVToken(
                app.loanToken,
                app.vToken,
                app.vTokenAmount
            );
            require(app.loanAmount > 0, "r2");
            app.vTokenAmount = 0;
        }

        if (amount == 0 || app.loanAmount <= amount) {
            amount = app.loanAmount;
            app.loanAmount = 0;
        } else {
            app.loanAmount = app.loanAmount.sub(amount);
        }
        app.vToken = vToken;

        if (vToken != address(0) && app.loanAmount > 0) {
            app.vTokenAmount = mintVToken(
                app.vToken,
                app.loanToken,
                app.loanAmount
            );
        }
        VaultLib.transferTokenOrBNB(app.owner, app.loanToken, amount);
        emit WithdrawLoan();
    }

    function borrow(
        uint256 _appID,
        address _collateralToken,
        uint256 _collateralAmount,
        uint256 _borrowAmount,
        uint256 _interestRate,
        uint256 _duration,
        address vToken
    ) public payable nonReentrant {
        if (_collateralToken == address(0)) {
            require(
                _collateralAmount == msg.value.sub(OPEN_POSITION_FEE),
                "r00"
            );
        } else {
            require(msg.value == OPEN_POSITION_FEE, "r0");
        }

        LoanApplication storage app = loanApplications[_appID];
        require(app.open == true, "r3");
        require(app.loanAmount >= _borrowAmount, "r4");
        bool valid = false;
        for (uint256 i = 0; i < app.interestRates.length; i++) {
            if (
                app.interestRates[i] == _interestRate &&
                app.durations[i] == _duration
            ) {
                valid = true;
                break;
            }
        }
        require(valid, "r5");
        valid = false;
        for (uint256 i = 0; i < app.availableCollateralTokens.length; i++) {
            if (app.availableCollateralTokens[i] == _collateralToken) {
                valid = true;
                break;
            }
        }
        require(valid, "r6");

        address[] memory path = loanCollateralPricePaths[app.id][
            _collateralToken
        ];
        uint256 collateralPrice = price(_collateralAmount, path);
        uint256 max = collateralPrice.mul(MAX_BORROW).div(10000);
        require(_borrowAmount <= max, "r7");

        borrowID++;
        if (_collateralToken != address(0)) {
            IERC20(_collateralToken).transferFrom(
                address(msg.sender),
                address(this),
                _collateralAmount
            );
        }

        uint256 vTokenAmount = 0;
        if (vToken != address(0)) {
            vTokenAmount = mintVToken(
                vToken,
                _collateralToken,
                _collateralAmount
            );
        }

        Borrow memory b = Borrow(
            app.id,
            msg.sender,
            _collateralToken,
            _collateralAmount,
            path,
            _borrowAmount,
            block.number,
            _interestRate,
            _duration,
            block.number + _duration,
            block.number,
            1,
            vToken,
            vTokenAmount
        );
        borrows[borrowID] = b;
        myBorrows[msg.sender].push(b);

        if (app.vTokenAmount > 0) {
            app.loanAmount = redeemVToken(
                app.loanToken,
                app.vToken,
                app.vTokenAmount
            );
            app.vTokenAmount = 0;
        }
        app.loanAmount = app.loanAmount.sub(_borrowAmount);
        VaultLib.transferTokenOrBNB(msg.sender, app.loanToken, _borrowAmount);

        if (app.vToken != address(0) && app.loanAmount > 0) {
            app.vTokenAmount = mintVToken(
                app.vToken,
                app.loanToken,
                app.loanAmount
            );
        }

        uint256 profit = OPEN_POSITION_FEE;
        if (totalDevFund < 10000 ether) {
            uint256 fee = OPEN_POSITION_FEE / 2;
            payable(dev).transfer(fee);
            profit = OPEN_POSITION_FEE.sub(fee);
            totalDevFund.add(fee);
        }
        VaultLib.transferProfit(profitShare, address(0), profit);

        emit CreateBorrow(borrowID);
    }

    function interestAmount(uint256 bid, uint256 blockNumber)
        public
        view
        returns (uint256)
    {
        if (blockNumber == 0) {
            blockNumber = block.number;
        }

        Borrow memory b = borrows[bid];
        if (b.dueDateBlock <= block.number) {
            blockNumber = b.dueDateBlock;
        }

        uint256 timePast = blockNumber.sub(b.lastPayBlock);

        uint256 totalInterest = b
            .borrowAmount
            .mul(b.interestRate)
            .div(1e18)
            .div(100);
        uint256 currentInterest = totalInterest.mul(timePast).div(b.duration);
        return currentInterest;
    }

    function repay(
        uint256 bid,
        uint256 amount,
        uint256 blockNumber
    ) public payable nonReentrant {
        Borrow storage b = borrows[bid];
        require(b.status == 1, "r0");
        LoanApplication storage app = loanApplications[b.appID];
        if (app.loanToken == address(0)) {
            require(amount == msg.value, "r2");
        }
        bool sendBlock = false;
        if (block.number.sub(blockNumber) <= 30) {
            // pay for closing the position, gap interest ~30 blocks, ~90secs
            sendBlock = true;
        } else {
            blockNumber = block.number;
        }

        uint256 interest = interestAmount(bid, blockNumber);
        uint256 principal = 0;
        if (amount >= b.borrowAmount.add(interest)) {
            // pay all
            amount = b.borrowAmount.add(interest);
            principal = b.borrowAmount;
            b.borrowAmount = 0;
        } else {
            if (sendBlock) {
                blockNumber = block.number;
                interest = interestAmount(bid, blockNumber);
            }
            if (amount >= interest) {
                principal = amount.sub(interest);
                b.borrowAmount = b.borrowAmount.sub(principal);
            }
        }

        if (b.borrowAmount == 0) {
            b.status = 2;
        }

        if (app.loanToken != address(0)) {
            IERC20(app.loanToken).transferFrom(
                address(msg.sender),
                address(this),
                amount
            );
        }
        b.lastPayBlock = blockNumber;
        uint256 fee = interest.mul(REPAY_FEE).div(10000);
        if (app.vTokenAmount > 0) {
            app.loanAmount = redeemVToken(
                app.loanToken,
                app.vToken,
                app.vTokenAmount
            );
            app.vTokenAmount = 0;
        }
        app.loanAmount = app.loanAmount.add(amount.sub(fee));
        uint256 profit = fee;
        if (gildToken.totalSupply() < gildToken.CAP()) {
            uint256 gildReward = interest;
            if (app.loanToken != address(0)) {
                address[] memory path = new address[](2);
                path[0] = app.loanToken;
                path[1] = wbnb;
                gildReward = price(interest, path);
            }
            gildToken.mint(app.owner, gildReward);
            gildToken.mint(b.owner, gildReward);
            if (gildToken.totalSupply() < 10000000 ether) {
                uint256 shareReward = fee / 2;
                gildToken.mint(dev, gildReward);
                VaultLib.transferTokenOrBNB(dev, app.loanToken, shareReward);
                profit = fee.sub(shareReward);
            }
        }
        VaultLib.transferProfit(profitShare, app.loanToken, profit);
        if (app.vToken != address(0)) {
            app.vTokenAmount = mintVToken(
                app.vToken,
                app.loanToken,
                app.loanAmount
            );
        }

        emit Repay(principal, interest, fee);
    }

    function applicationDetail(uint256 id)
        public
        view
        returns (
            address[] memory collateralTokens,
            uint256[] memory interestRates,
            uint256[] memory durations
        )
    {
        return (
            loanApplications[id].availableCollateralTokens,
            loanApplications[id].interestRates,
            loanApplications[id].durations
        );
    }

    function depositCollateral(
        uint256 bid,
        uint256 amount,
        address vToken
    ) public payable nonReentrant {
        Borrow storage b = borrows[bid];
        require(b.status == 1, "r1");

        if (b.collateralToken == address(0)) {
            require(amount == msg.value, "r2");
        } else {
            IERC20(b.collateralToken).transferFrom(
                address(msg.sender),
                address(this),
                amount
            );
        }

        if (b.vTokenAmount > 0) {
            b.collateralAmount = redeemVToken(
                b.collateralToken,
                b.vToken,
                b.vTokenAmount
            );
            b.vTokenAmount = 0;
        }
        b.collateralAmount = b.collateralAmount.add(amount);

        if (vToken != address(0)) {
            b.vTokenAmount = mintVToken(
                vToken,
                b.collateralToken,
                b.collateralAmount
            );
        }

        b.vToken = vToken;
        emit DepositCollateral();
    }

    function withdrawCollateral(
        uint256 bid,
        uint256 amount,
        address vToken
    ) public nonReentrant {
        Borrow storage b = borrows[bid];
        require(b.collateralAmount > 0, "r1");
        require(b.owner == msg.sender, "r2");
        if (b.borrowAmount == 0) {
            if (b.vTokenAmount > 0) {
                b.collateralAmount = redeemVToken(
                    b.collateralToken,
                    b.vToken,
                    b.vTokenAmount
                );
                b.vTokenAmount = 0;
            }
            uint256 a = b.collateralAmount;
            b.collateralAmount = 0;
            VaultLib.transferTokenOrBNB(b.owner, b.collateralToken, a);
            emit WithdrawCollateral();
            return;
        }

        uint256 remainingAmount = b.collateralAmount.sub(amount);
        uint256 collateralPrice = price(remainingAmount, b.collateralPricePath);
        uint256 r = risk(
            b.borrowAmount.add(interestAmount(bid, block.number)),
            collateralPrice
        );
        require(r / 1e18 < 80, "r3");

        if (b.vTokenAmount > 0) {
            b.collateralAmount = redeemVToken(
                b.collateralToken,
                b.vToken,
                b.vTokenAmount
            );
            b.vTokenAmount = 0;
        }
        b.collateralAmount = b.collateralAmount.sub(amount);
        if (vToken != address(0) && b.collateralAmount > 0) {
            (b.vTokenAmount) = mintVToken(
                b.vToken,
                b.collateralToken,
                b.collateralAmount
            );
        }
        b.vToken = vToken;
        VaultLib.transferTokenOrBNB(b.owner, b.collateralToken, amount);
        emit WithdrawCollateral();
    }

    function risk(uint256 borrowAmount, uint256 collateralPrice)
        public
        pure
        returns (uint256)
    {
        return borrowAmount.mul(100).mul(1e18).div(collateralPrice);
    }

    function borrowRisk(uint256 bid) public view returns (uint256) {
        Borrow memory b = borrows[bid];
        uint256 collateralPrice = price(
            b.collateralAmount,
            b.collateralPricePath
        );
        return
            risk(
                b.borrowAmount.add(interestAmount(bid, block.number)),
                collateralPrice
            );
    }

    function liquidate(uint256 bid) public nonReentrant {
        Borrow storage b = borrows[bid];
        require(b.status == 1, "r0");
        LoanApplication storage app = loanApplications[b.appID];
        uint256 interest = interestAmount(bid, block.number);
        if (b.dueDateBlock > block.number) {
            uint256 collateralPrice = price(
                b.collateralAmount,
                b.collateralPricePath
            );
            uint256 r = risk(b.borrowAmount.add(interest), collateralPrice);
            require(r / 1e18 >= 80, "r1");
        }

        address borrower = b.owner;
        uint256 toOwner = b.borrowAmount.add(interest);
        uint256 liquidatorPrize = toOwner.mul(LIQUIDATE_BPS).div(10000);
        uint256 devFee = toOwner.mul(PLATFORM_LIQUIDATE_BPS).div(10000);
        uint256 profitShareFee = devFee;
        uint256 total = toOwner + liquidatorPrize + devFee + profitShareFee;
        if (b.vTokenAmount > 0) {
            b.collateralAmount = redeemVToken(
                b.collateralToken,
                b.vToken,
                b.vTokenAmount
            );
            b.vTokenAmount = 0;
        }

        if (b.collateralToken != address(0)) {
            IERC20(b.collateralToken).approve(router, type(uint256).max);
        }
        (uint256 colleteralIn, uint256 totalSwap) = swap(
            total,
            b.collateralPricePath
        );
        if (b.collateralToken != address(0)) {
            IERC20(b.collateralToken).approve(router, 0);
        }
        b.borrowAmount = 0;
        b.collateralAmount = b.collateralAmount.sub(colleteralIn);
        if (b.collateralAmount > 0) {
            uint256 collateralAmount = b.collateralAmount;
            b.collateralAmount = 0;
            VaultLib.transferTokenOrBNB(
                b.owner,
                b.collateralToken,
                collateralAmount
            );
        }

        if (totalSwap <= toOwner) {
            app.loanAmount = app.loanAmount.add(totalSwap);
            emit Liquidate(
                bid,
                colleteralIn,
                total,
                totalSwap,
                toOwner,
                0,
                0,
                0
            );
            return;
        }

        app.loanAmount = app.loanAmount.add(toOwner);
        if (totalSwap < total) {
            uint256 remaining = (totalSwap.sub(toOwner)) / 3;
            liquidatorPrize = remaining;
            profitShareFee = remaining;
            devFee = remaining;
        }

        if (gildToken.totalSupply() < gildToken.CAP()) {
            uint256 gildReward = profitShareFee;
            if (app.loanToken != address(0)) {
                address[] memory path = new address[](2);
                path[0] = app.loanToken;
                path[1] = wbnb;
                gildReward = price(profitShareFee, path);
            }
            gildToken.mint(app.owner, gildReward);
            if (gildToken.totalSupply() < 10000000 ether) {
                gildToken.mint(dev, gildReward);
            }
        }

        VaultLib.transferTokenOrBNB(msg.sender, app.loanToken, liquidatorPrize);
        VaultLib.transferProfit(profitShare, app.loanToken, profitShareFee);
        VaultLib.transferTokenOrBNB(dev, app.loanToken, devFee);

        uint256 totalSend = toOwner + liquidatorPrize + devFee + profitShareFee;
        if (totalSwap > totalSend) {
            uint256 backAmount = totalSwap.sub(totalSend);
            VaultLib.transferTokenOrBNB(borrower, app.loanToken, backAmount);
        }

        b.status = 3;
        emit Liquidate(
            bid,
            colleteralIn,
            total,
            totalSwap,
            toOwner,
            liquidatorPrize,
            devFee,
            profitShareFee
        );
    }

    function price(uint256 amountIn, address[] memory path)
        internal
        view
        returns (uint256)
    {
        return
            IPancakeRouter02(router).getAmountsOut(amountIn, path)[
                path.length - 1
            ];
    }

    function swap(uint256 amountLoanOut, address[] memory path)
        internal
        returns (uint256 colleteralIn, uint256 amountOut)
    {
        uint256[] memory result;
        uint256 amountIn = IPancakeRouter02(router).getAmountsIn(
            amountLoanOut,
            path
        )[0];

        uint256 bf;
        address tokenOut = path[path.length - 1];
        if (tokenOut == wbnb) {
            bf = address(this).balance;
        } else {
            bf = IERC20(tokenOut).balanceOf(address(this));
        }

        if (path[0] == wbnb) {
            result = IPancakeRouter02(router).swapETHForExactTokens{
                value: amountIn
            }(amountLoanOut, path, address(this), block.timestamp + 600);
        } else if (tokenOut == wbnb) {
            result = IPancakeRouter02(router).swapExactTokensForETH(
                amountIn,
                amountLoanOut,
                path,
                address(this),
                block.timestamp + 600
            );
        } else {
            result = IPancakeRouter02(router).swapTokensForExactTokens(
                amountLoanOut,
                amountIn,
                path,
                address(this),
                block.timestamp + 600
            );
        }

        uint256 af;
        if (tokenOut == wbnb) {
            af = address(this).balance;
        } else {
            af = IERC20(tokenOut).balanceOf(address(this));
        }

        return (result[0], af.sub(bf));
    }

    function mintVToken(
        address vToken,
        address underlying,
        uint256 underlyingAmount
    ) internal returns (uint256 mintTokens) {
        uint256 bf = IERC20(vToken).balanceOf(address(this));
        if (underlying == address(0)) {
            IVenusBNB(vToken).mint{value: underlyingAmount}();
        } else {
            IERC20(underlying).approve(vToken, type(uint256).max);
            uint256 e = IVenusToken(vToken).mint(underlyingAmount);
            IERC20(underlying).approve(vToken, 0);
            require(e == 0, "m");
        }
        uint256 af = IERC20(vToken).balanceOf(address(this));
        return af.sub(bf);
    }

    function redeemVToken(
        address underlying,
        address vToken,
        uint256 vTokenAmount
    ) internal returns (uint256) {
        uint256 bf;
        if (underlying == address(0)) {
            bf = address(this).balance;
        } else {
            bf = IERC20(underlying).balanceOf(address(this));
        }
        uint256 e = IVenusToken(vToken).redeem(vTokenAmount);
        require(e == 0, "rd");
        uint256 af;
        if (underlying == address(0)) {
            af = address(this).balance;
        } else {
            af = IERC20(underlying).balanceOf(address(this));
        }
        return af.sub(bf);
    }

    function redeemVTokenView(address vToken, uint256 vTokenAmount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 rate = IVenusToken(vToken).exchangeRateStored();
        (MathError mathErr, uint256 redeemAmount) = mulScalarTruncate(
            Exp({mantissa: rate}),
            vTokenAmount
        );
        require(mathErr == MathError.NO_ERROR, "CAL_F");

        return (redeemAmount, rate);
    }

    function changeDev(address _dev) public {
        require(msg.sender == dev, "dev!");
        dev = _dev;
    }

    receive() external payable {}
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

contract TokenErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        COMPTROLLER_REJECTION,
        COMPTROLLER_CALCULATION_ERROR,
        INTEREST_RATE_MODEL_ERROR,
        INVALID_ACCOUNT_PAIR,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        INVALID_COLLATERAL_FACTOR,
        MATH_ERROR,
        MARKET_NOT_FRESH,
        MARKET_NOT_LISTED,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_IN_FAILED,
        TOKEN_TRANSFER_OUT_FAILED,
        TOKEN_PRICE_ERROR
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CarefulMath.sol";
import "./ExponentialNoError.sol";

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Venus
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract Exponential is CarefulMath, ExponentialNoError {
    /**
     * @dev Creates an exponential from numerator and denominator values.
     *      Note: Returns an error if (`num` * 10e18) > MAX_INT,
     *            or if `denom` is zero.
     */
    function getExp(uint256 num, uint256 denom)
        internal
        pure
        returns (MathError, Exp memory)
    {
        (MathError err0, uint256 scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint256 rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    /**
     * @dev Adds two exponentials, returning a new exponential.
     */
    function addExp(Exp memory a, Exp memory b)
        internal
        pure
        returns (MathError, Exp memory)
    {
        (MathError error, uint256 result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Subtracts two exponentials, returning a new exponential.
     */
    function subExp(Exp memory a, Exp memory b)
        internal
        pure
        returns (MathError, Exp memory)
    {
        (MathError error, uint256 result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Multiply an Exp by a scalar, returning a new Exp.
     */
    function mulScalar(Exp memory a, uint256 scalar)
        internal
        pure
        returns (MathError, Exp memory)
    {
        (MathError err0, uint256 scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mulScalarTruncate(Exp memory a, uint256 scalar)
        internal
        pure
        returns (MathError, uint256)
    {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mulScalarTruncateAddUInt(
        Exp memory a,
        uint256 scalar,
        uint256 addend
    ) internal pure returns (MathError, uint256) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    /**
     * @dev Divide an Exp by a scalar, returning a new Exp.
     */
    function divScalar(Exp memory a, uint256 scalar)
        internal
        pure
        returns (MathError, Exp memory)
    {
        (MathError err0, uint256 descaledMantissa) = divUInt(
            a.mantissa,
            scalar
        );
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    /**
     * @dev Divide a scalar by an Exp, returning a new Exp.
     */
    function divScalarByExp(uint256 scalar, Exp memory divisor)
        internal
        pure
        returns (MathError, Exp memory)
    {
        /*
          We are doing this as:
          getExp(mulUInt(expScale, scalar), divisor.mantissa)

          How it works:
          Exp = a / b;
          Scalar = s;
          `s / (a / b)` = `b * s / a` and since for an Exp `a = mantissa, b = expScale`
        */
        (MathError err0, uint256 numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    /**
     * @dev Divide a scalar by an Exp, then truncate to return an unsigned integer.
     */
    function divScalarByExpTruncate(uint256 scalar, Exp memory divisor)
        internal
        pure
        returns (MathError, uint256)
    {
        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }

    /**
     * @dev Multiplies two exponentials, returning a new exponential.
     */
    function mulExp(Exp memory a, Exp memory b)
        internal
        pure
        returns (MathError, Exp memory)
    {
        (MathError err0, uint256 doubleScaledProduct) = mulUInt(
            a.mantissa,
            b.mantissa
        );
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        // We add half the scale before dividing so that we get rounding instead of truncation.
        //  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717
        // Without this change, a result like 6.6...e-19 will be truncated to 0 instead of being rounded to 1e-18.
        (MathError err1, uint256 doubleScaledProductWithHalfScale) = addUInt(
            halfExpScale,
            doubleScaledProduct
        );
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint256 product) = divUInt(
            doubleScaledProductWithHalfScale,
            expScale
        );
        // The only error `div` can return is MathError.DIVISION_BY_ZERO but we control `expScale` and it is not zero.
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    /**
     * @dev Multiplies two exponentials given their mantissas, returning a new exponential.
     */
    function mulExp(uint256 a, uint256 b)
        internal
        pure
        returns (MathError, Exp memory)
    {
        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    /**
     * @dev Multiplies three exponentials, returning a new exponential.
     */
    function mulExp3(
        Exp memory a,
        Exp memory b,
        Exp memory c
    ) internal pure returns (MathError, Exp memory) {
        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    /**
     * @dev Divides two exponentials, returning a new exponential.
     *     (a/scale) / (b/scale) = (a/scale) * (scale/b) = a/b,
     *  which we can scale as an Exp by calling getExp(a.mantissa, b.mantissa)
     */
    function divExp(Exp memory a, Exp memory b)
        internal
        pure
        returns (MathError, Exp memory)
    {
        return getExp(a.mantissa, b.mantissa);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/IPancakeRouter02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IProfitShare.sol";

library VaultLib {
    using SafeMath for uint256;

    function checkInterestRates(uint256[] calldata _interestRates)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < _interestRates.length; i++) {
            if (
                _interestRates[i] < 0.02 ether || _interestRates[i] > 50 ether
            ) {
                // 0.02 % - 50%
                return false;
            }
        }

        return true;
    }

    function checkDurations(uint256[] calldata _durations)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < _durations.length; i++) {
            if (_durations[i] < 0 || _durations[i] > 52560000) {
                // if (_durations[i] < 86400 || _durations[i] > 52560000) {
                return false;
            }
        }

        return true;
    }

    function checkCollateralPath(
        address _loanToken,
        address[] calldata _collateralTokens,
        address[][] calldata _pricePaths,
        address wbnb
    ) internal pure returns (bool) {
        if (_loanToken == address(0)) {
            _loanToken = wbnb;
        }
        for (uint256 i = 0; i < _collateralTokens.length; i++) {
            address collateralToken = _collateralTokens[i];
            if (collateralToken == address(0)) {
                collateralToken = wbnb;
            }
            uint256 last = _pricePaths[i].length - 1;
            if (_loanToken != _pricePaths[i][last]) {
                return false;
            } else if (collateralToken != _pricePaths[i][0]) {
                return false;
            }
        }

        return true;
    }

    function validCollateral(
        address _loanToken,
        address[] calldata _collateralTokens
    ) internal pure returns (bool) {
        bool valid = true;
        for (uint256 i = 0; i < _collateralTokens.length; i++) {
            if (_loanToken == _collateralTokens[i]) {
                valid = false;
                break;
            }
        }
        return valid;
    }

    function transferTokenOrBNB(
        address receiver,
        address token,
        uint256 amount
    ) internal {
        if (token == address(0)) {
            payable(receiver).transfer(amount);
        } else {
            IERC20(token).transfer(receiver, amount);
        }
    }

    function transferProfit(
        address profitShare,
        address token,
        uint256 amount
    ) internal {
        if (token == address(0)) {
            IProfitShare(profitShare).addProfitBNB{value: amount}();
        } else {
            IERC20(token).approve(profitShare, type(uint256).max);
            IProfitShare(profitShare).addProfit(token, amount);
            IERC20(token).approve(profitShare, 0);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// NO FARMING YOU WILL GET GILD ONLY YOUR WORK (LENDING, BORROWING)!
contract GildToken is ERC20, Ownable {
    uint256 public constant CAP = 21000000000000000000000000; // 21M

    constructor() ERC20("Gild Token", "GILD") {
        _mint(msg.sender, 1 ether); // mint 1 token for making GILD-BNB LP Token
    }

    // onlyOwner = Vault
    function mint(address to, uint256 amount) public onlyOwner {
        if (totalSupply() < CAP) {
            if (totalSupply() + amount > CAP) {
                amount = CAP - totalSupply();
            }

            _mint(to, amount);
        }
    }

    function mintTest(address to, uint256 amount) public {
        if (totalSupply() < CAP) {
            if (totalSupply() + amount > CAP) {
                amount = CAP - totalSupply();
            }

            _mint(to, amount);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface IPancakeRouter02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVenusBNB {
    function mint() external payable;

    function redeem(uint256 redeemTokens) external returns (uint256);

    function exchangeRateStored() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVenusToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function exchangeRateStored() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Careful Math
 * @author Venus
 * @notice Derived from OpenZeppelin's SafeMath library
 *         https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
contract CarefulMath {
    /**
     * @dev Possible error codes that we can return
     */
    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    /**
     * @dev Multiplies two numbers, returns an error on overflow.
     */
    function mulUInt(uint256 a, uint256 b)
        internal
        pure
        returns (MathError, uint256)
    {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint256 c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function divUInt(uint256 a, uint256 b)
        internal
        pure
        returns (MathError, uint256)
    {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    /**
     * @dev Subtracts two numbers, returns an error on overflow (i.e. if subtrahend is greater than minuend).
     */
    function subUInt(uint256 a, uint256 b)
        internal
        pure
        returns (MathError, uint256)
    {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    /**
     * @dev Adds two numbers, returns an error on overflow.
     */
    function addUInt(uint256 a, uint256 b)
        internal
        pure
        returns (MathError, uint256)
    {
        uint256 c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    /**
     * @dev add a and b and then subtract c
     */
    function addThenSubUInt(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (MathError, uint256) {
        (MathError err0, uint256 sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract ExponentialNoError {
    uint256 constant expScale = 1e18;
    uint256 constant doubleScale = 1e36;
    uint256 constant halfExpScale = expScale / 2;
    uint256 constant mantissaOne = expScale;

    struct Exp {
        uint256 mantissa;
    }

    struct Double {
        uint256 mantissa;
    }

    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
     */
    function truncate(Exp memory exp) internal pure returns (uint256) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / expScale;
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mul_ScalarTruncate(Exp memory a, uint256 scalar)
        internal
        pure
        returns (uint256)
    {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mul_ScalarTruncateAddUInt(
        Exp memory a,
        uint256 scalar,
        uint256 addend
    ) internal pure returns (uint256) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

    /**
     * @dev Checks if first Exp is less than second Exp.
     */
    function lessThanExp(Exp memory left, Exp memory right)
        internal
        pure
        returns (bool)
    {
        return left.mantissa < right.mantissa;
    }

    /**
     * @dev Checks if left Exp <= right Exp.
     */
    function lessThanOrEqualExp(Exp memory left, Exp memory right)
        internal
        pure
        returns (bool)
    {
        return left.mantissa <= right.mantissa;
    }

    /**
     * @dev Checks if left Exp > right Exp.
     */
    function greaterThanExp(Exp memory left, Exp memory right)
        internal
        pure
        returns (bool)
    {
        return left.mantissa > right.mantissa;
    }

    /**
     * @dev returns true if Exp is exactly zero
     */
    function isZeroExp(Exp memory value) internal pure returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint224)
    {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b)
        internal
        pure
        returns (Exp memory)
    {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b)
        internal
        pure
        returns (Double memory)
    {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint256 a, uint256 b) internal pure returns (uint256) {
        return add_(a, b, "addition overflow");
    }

    function add_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b)
        internal
        pure
        returns (Exp memory)
    {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b)
        internal
        pure
        returns (Double memory)
    {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b)
        internal
        pure
        returns (Exp memory)
    {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint256 a, Exp memory b) internal pure returns (uint256) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b)
        internal
        pure
        returns (Double memory)
    {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint256 b)
        internal
        pure
        returns (Double memory)
    {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint256 a, Double memory b) internal pure returns (uint256) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b)
        internal
        pure
        returns (Exp memory)
    {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint256 a, Exp memory b) internal pure returns (uint256) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b)
        internal
        pure
        returns (Double memory)
    {
        return
            Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint256 b)
        internal
        pure
        returns (Double memory)
    {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint256 a, Double memory b) internal pure returns (uint256) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint256 a, uint256 b) internal pure returns (uint256) {
        return div_(a, b, "divide by zero");
    }

    function div_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint256 a, uint256 b)
        internal
        pure
        returns (Double memory)
    {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IProfitShare {
    function addProfit(address token, uint256 amount) external;

    function addProfitBNB() external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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