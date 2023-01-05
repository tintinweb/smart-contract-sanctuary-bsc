// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import "../interfaces/IStrategy.sol";
import "../interfaces/IWETH.sol";
import "../interfaces/IWooAccessManager.sol";
import "../interfaces/IVaultV2.sol";
import "../interfaces/IMasterChefWoo.sol";

import "./WooWithdrawManagerV2.sol";
import "./WooLendingManager.sol";

import "../libraries/TransferHelper.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract WooSuperChargerVaultV2 is ERC20, Ownable, Pausable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;

    event Deposit(address indexed depositor, address indexed receiver, uint256 assets, uint256 shares);
    event RequestWithdraw(address indexed owner, uint256 assets, uint256 shares);
    event InstantWithdraw(address indexed owner, uint256 assets, uint256 shares, uint256 fees);
    event WeeklySettleStarted(address indexed caller, uint256 totalRequestedShares, uint256 weeklyRepayAmount);
    event WeeklySettleEnded(
        address indexed caller,
        uint256 totalBalance,
        uint256 lendingBalance,
        uint256 reserveBalance
    );
    event ReserveVaultMigrated(address indexed user, address indexed oldVault, address indexed newVault);
    event SuperChargerVaultMigrated(
        address indexed user,
        address indexed oldVault,
        address indexed newVault,
        uint256 amount
    );

    event LendingManagerUpdated(address formerLendingManager, address newLendingManager);
    event WithdrawManagerUpdated(address formerWithdrawManager, address newWithdrawManager);
    event InstantWithdrawFeeRateUpdated(uint256 formerFeeRate, uint256 newFeeRate);

    /* ----- State Variables ----- */

    address constant ETH_PLACEHOLDER_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    IVaultV2 public reserveVault;
    address public migrationVault;
    WooLendingManager public lendingManager;
    WooWithdrawManagerV2 public withdrawManager;

    address public immutable want;
    address public immutable weth;
    IWooAccessManager public immutable accessManager;

    mapping(address => uint256) public costSharePrice;
    mapping(address => uint256) public requestedWithdrawShares; // Requested withdrawn amount (in assets, NOT shares)
    uint256 public requestedTotalShares;
    EnumerableSet.AddressSet private requestUsers;

    uint256 public instantWithdrawCap; // Max instant withdraw amount (in assets, per week)
    uint256 public instantWithdrawnAmount; // Withdrawn amout already consumed (in assets, per week)

    bool public isSettling;

    address public treasury = 0x815D4517427Fc940A90A5653cdCEA1544c6283c9;
    uint256 public instantWithdrawFeeRate = 30; // 1 in 10000th. default: 30 -> 0.3%
    uint256 public maxWithdrawCount = 300;

    address public masterChef;
    uint256 public pid;

    constructor(
        address _weth,
        address _want,
        address _accessManager
    )
        ERC20(
            string(abi.encodePacked("WOOFi Super Charger ", ERC20(_want).name())),
            string(abi.encodePacked("we", ERC20(_want).symbol()))
        )
    {
        require(_weth != address(0), "WooSuperChargerVault: !weth");
        require(_want != address(0), "WooSuperChargerVault: !want");
        require(_accessManager != address(0), "WooSuperChargerVault: !accessManager");

        weth = _weth;
        want = _want;
        accessManager = IWooAccessManager(_accessManager);
    }

    function init(
        address _reserveVault,
        address _lendingManager,
        address payable _withdrawManager
    ) external onlyOwner {
        require(_reserveVault != address(0), "WooSuperChargerVault: !_reserveVault");
        require(_lendingManager != address(0), "WooSuperChargerVault: !_lendingManager");
        require(_withdrawManager != address(0), "WooSuperChargerVault: !_withdrawManager");

        reserveVault = IVaultV2(_reserveVault);
        require(reserveVault.want() == want);
        lendingManager = WooLendingManager(_lendingManager);
        withdrawManager = WooWithdrawManagerV2(_withdrawManager);
    }

    modifier onlyAdmin() {
        require(owner() == msg.sender || accessManager.isVaultAdmin(msg.sender), "WooSuperChargerVault: !ADMIN");
        _;
    }

    modifier onlyLendingManager() {
        require(msg.sender == address(lendingManager), "WooSuperChargerVault: !lendingManager");
        _;
    }

    /* ----- External Functions ----- */

    function setMasterChef(address _masterChef, uint256 _pid) external onlyOwner {
        require(_masterChef != address(0), "!_masterChef");
        masterChef = _masterChef;
        pid = _pid;
        (IERC20 weToken, , , , ) = IMasterChefWoo(masterChef).poolInfo(pid);
        require(address(weToken) == address(this), "!pid");
    }

    function stakedShares(address _user) public view returns (uint256 shares) {
        if (masterChef == address(0)) {
            shares = 0;
        } else {
            (shares, ) = IMasterChefWoo(masterChef).userInfo(pid, _user);
        }
    }

    function deposit(uint256 amount) external payable whenNotPaused nonReentrant {
        _deposit(amount, msg.sender);
    }

    function deposit(uint256 amount, address receiver) external payable whenNotPaused nonReentrant {
        _deposit(amount, receiver);
    }

    function _deposit(uint256 amount, address receiver) private {
        if (amount == 0) {
            return;
        }

        lendingManager.accureInterest();
        uint256 shares = _shares(amount, getPricePerFullShare());
        require(shares > 0, "!shares");

        uint256 sharesBefore = balanceOf(receiver) + stakedShares(receiver);
        uint256 costBefore = costSharePrice[receiver];
        uint256 costAfter = (sharesBefore * costBefore + amount * 1e18) / (sharesBefore + shares);

        costSharePrice[receiver] = costAfter;

        if (want == weth) {
            require(amount == msg.value, "WooSuperChargerVault: msg.value_INSUFFICIENT");
            reserveVault.deposit{value: msg.value}(amount);
        } else {
            TransferHelper.safeTransferFrom(want, msg.sender, address(this), amount);
            TransferHelper.safeApprove(want, address(reserveVault), amount);
            reserveVault.deposit(amount);
        }
        _mint(receiver, shares);

        instantWithdrawCap = instantWithdrawCap + amount / 10;

        emit Deposit(msg.sender, receiver, amount, shares);
    }

    function instantWithdraw(uint256 amount) external whenNotPaused nonReentrant {
        _instantWithdrawShares(_sharesUpLatest(amount), msg.sender);
    }

    function instantWithdrawAll() external whenNotPaused nonReentrant {
        _instantWithdrawShares(balanceOf(msg.sender), msg.sender);
    }

    function _instantWithdrawShares(uint256 shares, address owner) private {
        require(shares > 0, "WooSuperChargerVault: !amount");
        require(!isSettling, "WooSuperChargerVault: NOT_ALLOWED_IN_SETTLING");

        if (instantWithdrawnAmount >= instantWithdrawCap) {
            // NOTE: no more instant withdraw quota.
            return;
        }

        lendingManager.accureInterest();
        uint256 amount = _assets(shares);
        require(amount <= instantWithdrawCap - instantWithdrawnAmount, "WooSuperChargerVault: OUT_OF_CAP");

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }
        _burn(owner, shares);

        uint256 reserveShares = _sharesUp(amount, reserveVault.getPricePerFullShare());
        reserveVault.withdraw(reserveShares);

        uint256 fee = accessManager.isZeroFeeVault(msg.sender) ? 0 : (amount * instantWithdrawFeeRate) / 10000;
        if (want == weth) {
            TransferHelper.safeTransferETH(treasury, fee);
            TransferHelper.safeTransferETH(owner, amount - fee);
        } else {
            TransferHelper.safeTransfer(want, treasury, fee);
            TransferHelper.safeTransfer(want, owner, amount - fee);
        }

        instantWithdrawnAmount = instantWithdrawnAmount + amount;

        emit InstantWithdraw(owner, amount, reserveShares, fee);
    }

    function migrateToNewVault() external whenNotPaused nonReentrant {
        _migrateToNewVault(msg.sender);
    }

    function _migrateToNewVault(address owner) private {
        require(owner != address(0), "WooSuperChargerVault: !owner");
        require(migrationVault != address(0), "WooSuperChargerVault: !migrationVault");

        WooSuperChargerVaultV2 newVault = WooSuperChargerVaultV2(payable(migrationVault));
        require(newVault.want() == want, "WooSuperChargerVault: !WANT_newVault");

        uint256 shares = balanceOf(owner);
        if (shares == 0) {
            return;
        }

        lendingManager.accureInterest();
        uint256 amount = _assets(shares);

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }
        _burn(owner, shares);

        uint256 reserveShares = _sharesUp(amount, reserveVault.getPricePerFullShare());
        reserveVault.withdraw(reserveShares);

        if (want == weth) {
            newVault.deposit{value: amount}(amount, owner);
        } else {
            TransferHelper.safeApprove(want, address(newVault), amount);
            newVault.deposit(amount, owner);
        }

        emit SuperChargerVaultMigrated(owner, address(this), address(newVault), amount);
    }

    function requestWithdraw(uint256 amount) external whenNotPaused nonReentrant {
        _requestWithdrawShares(_sharesUpLatest(amount));
    }

    function requestWithdrawAll() external whenNotPaused nonReentrant {
        _requestWithdrawShares(balanceOf(msg.sender));
    }

    function _requestWithdrawShares(uint256 shares) private {
        require(shares > 0, "WooSuperChargerVault: !amount");
        require(!isSettling, "WooSuperChargerVault: CANNOT_WITHDRAW_IN_SETTLING");
        require(requestUsers.length() <= maxWithdrawCount, "WooSuperChargerVault: MAX_WITHDRAW_COUNT");

        address owner = msg.sender;

        lendingManager.accureInterest();
        uint256 amount = _assets(shares);
        TransferHelper.safeTransferFrom(address(this), owner, address(this), shares);

        requestedWithdrawShares[owner] = requestedWithdrawShares[owner] + shares;
        requestedTotalShares = requestedTotalShares + shares;
        requestUsers.add(owner);

        emit RequestWithdraw(owner, amount, shares);
    }

    function requestedTotalAmount() public view returns (uint256) {
        return _assets(requestedTotalShares);
    }

    function totalRequestedUserNumber() external view returns (uint256 totalNumber) {
        return requestUsers.length();
    }

    function requestedWithdrawAmount(address user) public view returns (uint256) {
        return _assets(requestedWithdrawShares[user]);
    }

    function available() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function reserveBalance() public view returns (uint256) {
        return _assets(IERC20(address(reserveVault)).balanceOf(address(this)), reserveVault.getPricePerFullShare());
    }

    function lendingBalance() public view returns (uint256) {
        return lendingManager.debtAfterPerfFee();
    }

    // Returns the total balance (assets), which is avaiable + reserve + lending.
    function balance() public view returns (uint256) {
        return available() + reserveBalance() + lendingBalance();
    }

    function getPricePerFullShare() public view returns (uint256) {
        return totalSupply() == 0 ? 1e18 : (balance() * 1e18) / totalSupply();
    }

    // --- For WooLendingManager --- //

    function maxBorrowableAmount() public view returns (uint256) {
        uint256 resBal = reserveBalance();
        uint256 instWithdrawBal = instantWithdrawCap - instantWithdrawnAmount;
        return resBal > instWithdrawBal ? resBal - instWithdrawBal : 0;
    }

    function borrowFromLendingManager(uint256 amount, address fundAddr) external onlyLendingManager {
        require(!isSettling, "IN SETTLING");
        require(amount <= maxBorrowableAmount(), "INSUFF_AMOUNT_FOR_BORROW");
        uint256 sharesToWithdraw = _sharesUp(amount, reserveVault.getPricePerFullShare());
        reserveVault.withdraw(sharesToWithdraw);
        if (want == weth) {
            IWETH(weth).deposit{value: amount}();
        }
        TransferHelper.safeTransfer(want, fundAddr, amount);
    }

    function repayFromLendingManager(uint256 amount) external onlyLendingManager {
        TransferHelper.safeTransferFrom(want, msg.sender, address(this), amount);
        if (want == weth) {
            IWETH(weth).withdraw(amount);
            reserveVault.deposit{value: amount}(amount);
        } else {
            TransferHelper.safeApprove(want, address(reserveVault), amount);
            reserveVault.deposit(amount);
        }
    }

    // --- Admin operations --- //

    function weeklyNeededAmountForWithdraw() public view returns (uint256) {
        uint256 reserveBal = reserveBalance();
        uint256 requestedAmount = requestedTotalAmount();
        uint256 afterBal = balance() - requestedAmount;

        return reserveBal >= requestedAmount + afterBal / 10 ? 0 : requestedAmount + afterBal / 10 - reserveBal;
    }

    function startWeeklySettle() external onlyAdmin {
        require(!isSettling, "IN_SETTLING");
        isSettling = true;
        lendingManager.accureInterest();
        emit WeeklySettleStarted(msg.sender, requestedTotalShares, weeklyNeededAmountForWithdraw());
    }

    function endWeeklySettle() public onlyAdmin {
        require(isSettling, "!SETTLING");
        require(weeklyNeededAmountForWithdraw() == 0, "WEEKLY_REPAY_NOT_CLEARED");

        // NOTE: Do need accureInterest here, since it's already been updated in `startWeeklySettle`
        uint256 sharePrice = getPricePerFullShare();

        isSettling = false;
        uint256 totalWithdrawAmount = requestedTotalAmount();

        if (totalWithdrawAmount != 0) {
            uint256 shares = _sharesUp(totalWithdrawAmount, reserveVault.getPricePerFullShare());
            reserveVault.withdraw(shares);

            if (want == weth) {
                IWETH(weth).deposit{value: totalWithdrawAmount}();
            }
            require(available() >= totalWithdrawAmount);

            uint256 length = requestUsers.length();
            for (uint256 i = 0; i < length; i++) {
                address user = requestUsers.at(0);

                withdrawManager.addWithdrawAmount(user, (requestedWithdrawShares[user] * sharePrice) / 1e18);

                requestedWithdrawShares[user] = 0;
                requestUsers.remove(user);
            }

            _burn(address(this), requestedTotalShares);
            requestedTotalShares = 0;

            TransferHelper.safeTransfer(want, address(withdrawManager), totalWithdrawAmount);
        }

        instantWithdrawnAmount = 0;

        lendingManager.accureInterest();
        uint256 totalBalance = balance();
        instantWithdrawCap = totalBalance / 10;

        emit WeeklySettleEnded(msg.sender, totalBalance, lendingBalance(), reserveBalance());
    }

    function migrateReserveVault(address _vault) external onlyOwner {
        require(_vault != address(0), "!_vault");

        uint256 preBal = (want == weth) ? address(this).balance : available();
        reserveVault.withdraw(IERC20(address(reserveVault)).balanceOf(address(this)));
        uint256 afterBal = (want == weth) ? address(this).balance : available();
        uint256 reserveAmount = afterBal - preBal;

        address oldVault = address(reserveVault);
        reserveVault = IVaultV2(_vault);
        require(reserveVault.want() == want, "INVALID_WANT");
        if (want == weth) {
            reserveVault.deposit{value: reserveAmount}(reserveAmount);
        } else {
            TransferHelper.safeApprove(want, address(reserveVault), reserveAmount);
            reserveVault.deposit(reserveAmount);
        }

        emit ReserveVaultMigrated(msg.sender, oldVault, _vault);
    }

    function inCaseTokenGotStuck(address stuckToken) external onlyOwner {
        if (stuckToken == ETH_PLACEHOLDER_ADDR) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        } else {
            uint256 amount = IERC20(stuckToken).balanceOf(address(this));
            TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
        }
    }

    function setLendingManager(address _lendingManager) external onlyOwner {
        address formerManager = address(lendingManager);
        lendingManager = WooLendingManager(_lendingManager);
        emit LendingManagerUpdated(formerManager, _lendingManager);
    }

    function setWithdrawManager(address payable _withdrawManager) external onlyOwner {
        address formerManager = address(withdrawManager);
        withdrawManager = WooWithdrawManagerV2(_withdrawManager);
        emit WithdrawManagerUpdated(formerManager, _withdrawManager);
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setMaxWithdrawCount(uint256 _maxWithdrawCount) external onlyOwner {
        maxWithdrawCount = _maxWithdrawCount;
    }

    function setInstantWithdrawFeeRate(uint256 _feeRate) external onlyOwner {
        uint256 formerFeeRate = instantWithdrawFeeRate;
        instantWithdrawFeeRate = _feeRate;
        emit InstantWithdrawFeeRateUpdated(formerFeeRate, _feeRate);
    }

    function setInstantWithdrawCap(uint256 _instantWithdrawCap) external onlyOwner {
        instantWithdrawCap = _instantWithdrawCap;
    }

    function setMigrationVault(address _vault) external onlyOwner {
        migrationVault = _vault;
        WooSuperChargerVaultV2 newVault = WooSuperChargerVaultV2(payable(_vault));
        require(newVault.want() == want, "WooSuperChargerVault: !WANT_vault");
    }

    function pause() public onlyAdmin {
        _pause();
    }

    function unpause() external onlyAdmin {
        _unpause();
    }

    receive() external payable {}

    function _assets(uint256 shares) private view returns (uint256) {
        return _assets(shares, getPricePerFullShare());
    }

    function _assets(uint256 shares, uint256 sharePrice) private pure returns (uint256) {
        return (shares * sharePrice) / 1e18;
    }

    function _shares(uint256 assets, uint256 sharePrice) private pure returns (uint256) {
        return (assets * 1e18) / sharePrice;
    }

    function _sharesUpLatest(uint256 assets) private returns (uint256) {
        lendingManager.accureInterest();
        return _sharesUp(assets, getPricePerFullShare());
    }

    function _sharesUp(uint256 assets, uint256 sharePrice) private pure returns (uint256) {
        uint256 shares = (assets * 1e18) / sharePrice;
        return _assets(shares, sharePrice) == assets ? shares : shares + 1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Wrapped ETH.
interface IWETH {
    /// @dev Deposit ETH into WETH
    function deposit() external payable;

    /// @dev Transfer WETH to receiver
    /// @param to address of WETH receiver
    /// @param value amount of WETH to transfer
    /// @return get true when succeed, else false
    function transfer(address to, uint256 value) external returns (bool);

    /// @dev Withdraw WETH to ETH
    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title Reward manager interface for WooFi Swap.
/// @notice this is for swap rebate or potential incentive program
interface IWooAccessManager {
    /* ----- Events ----- */

    event FeeAdminUpdated(address indexed feeAdmin, bool flag);

    event VaultAdminUpdated(address indexed vaultAdmin, bool flag);

    event RebateAdminUpdated(address indexed rebateAdmin, bool flag);

    event ZeroFeeVaultUpdated(address indexed vault, bool flag);

    /* ----- External Functions ----- */

    function isFeeAdmin(address feeAdmin) external returns (bool);

    function isVaultAdmin(address vaultAdmin) external returns (bool);

    function isRebateAdmin(address rebateAdmin) external returns (bool);

    function isZeroFeeVault(address vault) external returns (bool);

    /* ----- Admin Functions ----- */

    /// @notice Sets feeAdmin
    function setFeeAdmin(address feeAdmin, bool flag) external;

    /// @notice Sets vaultAdmin
    function setVaultAdmin(address vaultAdmin, bool flag) external;

    /// @notice Sets rebateAdmin
    function setRebateAdmin(address rebateAdmin, bool flag) external;

    /// @notice Sets zeroFeeVault
    function setZeroFeeVault(address vault, bool flag) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
interface IStrategy {
    function vault() external view returns (address);

    function want() external view returns (address);

    function beforeDeposit() external;

    function beforeWithdraw() external;

    function deposit() external;

    function withdraw(uint256) external;

    function balanceOf() external view returns (uint256);

    function balanceOfWant() external view returns (uint256);

    function balanceOfPool() external view returns (uint256);

    function harvest() external;

    function retireStrat() external;

    function emergencyExit() external;

    function paused() external view returns (bool);

    function inCaseTokensGetStuck(address stuckToken) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

interface IVaultV2 {
    function want() external view returns (address);

    function weth() external view returns (address);

    function deposit(uint256 amount) external payable;

    function withdraw(uint256 shares) external;

    function earn() external;

    function available() external view returns (uint256);

    function balance() external view returns (uint256);

    function getPricePerFullShare() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IRewarder.sol";

interface IMasterChefWoo {
    event PoolAdded(uint256 poolId, uint256 allocPoint, IERC20 weToken, IRewarder rewarder);
    event PoolSet(uint256 poolId, uint256 allocPoint, IRewarder rewarder);
    event PoolUpdated(uint256 poolId, uint256 lastRewardBlock, uint256 supply, uint256 accTokenPerShare);
    event XWooPerBlockUpdated(uint256 xWooPerBlock);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 weToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
        IRewarder rewarder;
    }

    // System-level function
    function setXWooPerBlock(uint256 _xWooPerBlock) external;

    // Pool-related functions
    function poolLength() external view returns (uint256);

    function add(
        uint256 allocPoint,
        IERC20 weToken,
        IRewarder rewarder
    ) external;

    function set(
        uint256 pid,
        uint256 allocPoint,
        IRewarder rewarder
    ) external;

    function massUpdatePools() external;

    function updatePool(uint256 pid) external;

    // User-related functions
    function pendingXWoo(uint256 pid, address user) external view returns (uint256, uint256);

    function deposit(uint256 pid, uint256 amount) external;

    function withdraw(uint256 pid, uint256 amount) external;

    function harvest(uint256 pid) external;

    function emergencyWithdraw(uint256 pid) external;

    function userInfo(uint256 pid, address user) external view returns (uint256 amount, uint256 rewardDebt);

    function poolInfo(uint256 pid)
        external
        view
        returns (
            IERC20 weToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accTokenPerShare,
            IRewarder rewarder
        );
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "./WooSuperChargerVaultV2.sol";
import "../interfaces/IWETH.sol";
import "../interfaces/IWooAccessManager.sol";
import "../interfaces/IWooPPV2.sol";

import "../libraries/TransferHelper.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract WooLendingManager is Ownable, ReentrancyGuard {
    event Borrow(address indexed user, uint256 assets);
    event Repay(address indexed user, uint256 assets, uint256 perfFee);
    event InterestRateUpdated(address indexed user, uint256 oldInterest, uint256 newInterest);

    address public weth;
    address public want;
    address public accessManager;
    address public wooPP;
    WooSuperChargerVaultV2 public superChargerVault;

    uint256 public borrowedPrincipal;
    uint256 public borrowedInterest;

    uint256 public perfRate = 1000; // 1 in 10000th. 1000 = 10%
    address public treasury;

    uint256 public interestRate; // 1 in 10000th. 1 = 0.01% (1 bp), 10 = 0.1% (10 bps)
    uint256 public lastAccuredTs; // Timestamp of last accured interests

    mapping(address => bool) public isBorrower;

    address constant ETH_PLACEHOLDER_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor() {}

    function init(
        address _weth,
        address _want,
        address _accessManager,
        address _wooPP,
        address payable _superChargerVault
    ) external onlyOwner {
        weth = _weth;
        want = _want;
        accessManager = _accessManager;
        wooPP = _wooPP;
        superChargerVault = WooSuperChargerVaultV2(_superChargerVault);
        lastAccuredTs = block.timestamp;
        treasury = 0x4094D7A17a387795838c7aba4687387B0d32BCf3;
    }

    modifier onlyAdmin() {
        require(
            owner() == msg.sender || IWooAccessManager(accessManager).isVaultAdmin(msg.sender),
            "WooLendingManager: !ADMIN"
        );
        _;
    }

    modifier onlyBorrower() {
        require(isBorrower[msg.sender], "WooLendingManager: !borrower");
        _;
    }

    modifier onlySuperChargerVault() {
        require(msg.sender == address(superChargerVault), "WooLendingManager: !superChargerVault");
        _;
    }

    function setSuperChargerVault(address payable _wooSuperCharger) external onlyOwner {
        superChargerVault = WooSuperChargerVaultV2(_wooSuperCharger);
    }

    function setWooPP(address _wooPP) external onlyOwner {
        wooPP = _wooPP;
    }

    function setBorrower(address _borrower, bool _isBorrower) external onlyOwner {
        isBorrower[_borrower] = _isBorrower;
    }

    function setPerfRate(uint256 _rate) external onlyAdmin {
        require(_rate < 10000);
        perfRate = _rate;
    }

    function debt() public view returns (uint256 assets) {
        return borrowedPrincipal + borrowedInterest;
    }

    function debtAfterPerfFee() public view returns (uint256 assets) {
        uint256 perfFee = (borrowedInterest * perfRate) / 10000;
        return borrowedPrincipal + borrowedInterest - perfFee;
    }

    function borrowState()
        external
        view
        returns (
            uint256 total,
            uint256 principal,
            uint256 interest,
            uint256 borrowable
        )
    {
        total = debt();
        principal = borrowedPrincipal;
        interest = borrowedInterest;
        borrowable = superChargerVault.maxBorrowableAmount();
    }

    function accureInterest() public {
        uint256 currentTs = block.timestamp;

        // CAUTION: block.timestamp may be out of order
        if (currentTs <= lastAccuredTs) {
            return;
        }

        uint256 duration = currentTs - lastAccuredTs;

        // interestRate is in 10000th.
        // 31536000 = 365 * 24 * 3600 (1 year of seconds)
        uint256 interest = (borrowedPrincipal * interestRate * duration) / 31536000 / 10000;

        borrowedInterest = borrowedInterest + interest;
        lastAccuredTs = currentTs;
    }

    function setInterestRate(uint256 _rate) external onlyAdmin {
        require(_rate <= 50000, "RATE_INVALID"); // NOTE: rate < 500%
        accureInterest();
        uint256 oldInterest = interestRate;
        interestRate = _rate;
        emit InterestRateUpdated(msg.sender, oldInterest, _rate);
    }

    function setTreasury(address _treasury) external onlyAdmin {
        require(_treasury != address(0), "WooLendingManager: !_treasury");
        treasury = _treasury;
    }

    function maxBorrowableAmount() external view returns (uint256) {
        return superChargerVault.maxBorrowableAmount();
    }

    /// @dev Borrow the fund from super charger and then deposit directly into WooPP.
    /// @param amount the borrowing amount
    function borrow(uint256 amount) external onlyBorrower {
        require(amount > 0, "!AMOUNT");

        accureInterest();
        borrowedPrincipal = borrowedPrincipal + amount;

        uint256 preBalance = IERC20(want).balanceOf(address(this));
        superChargerVault.borrowFromLendingManager(amount, address(this));
        uint256 afterBalance = IERC20(want).balanceOf(address(this));
        require(afterBalance - preBalance == amount, "WooLendingManager: BORROW_AMOUNT_ERROR");

        TransferHelper.safeApprove(want, wooPP, amount);
        IWooPPV2(wooPP).deposit(want, amount);

        emit Borrow(msg.sender, amount);
    }

    // NOTE: this is the view functiono;
    // Remember to call the accureInterest to ensure the latest repayment state.
    function weeklyRepayment() public view returns (uint256 repayAmount) {
        uint256 neededAmount = superChargerVault.weeklyNeededAmountForWithdraw();
        if (neededAmount == 0) {
            return 0;
        }
        if (neededAmount <= borrowedInterest) {
            repayAmount = (neededAmount * 10000) / (uint256(10000) - perfRate);
        } else {
            repayAmount = neededAmount - borrowedInterest + ((borrowedInterest * 10000) / (uint256(10000) - perfRate));
        }
        repayAmount = repayAmount + 1;
    }

    function weeklyRepaymentBreakdown()
        public
        view
        returns (
            uint256 repayAmount,
            uint256 principal,
            uint256 interest,
            uint256 perfFee
        )
    {
        uint256 neededAmount = superChargerVault.weeklyNeededAmountForWithdraw();
        if (neededAmount == 0) {
            return (0, 0, 0, 0);
        }
        if (neededAmount <= borrowedInterest) {
            repayAmount = (neededAmount * 10000) / (uint256(10000) - perfRate);
            principal = 0;
            interest = neededAmount;
        } else {
            repayAmount = neededAmount - borrowedInterest + ((borrowedInterest * 10000) / (uint256(10000) - perfRate));
            principal = neededAmount - borrowedInterest;
            interest = borrowedInterest;
        }
        repayAmount = repayAmount + 1;
        perfFee = repayAmount - neededAmount;
    }

    function repayWeekly() external onlyBorrower returns (uint256 repaidAmount) {
        accureInterest();
        repaidAmount = weeklyRepayment();
        if (repaidAmount != 0) {
            repay(repaidAmount);
        } else {
            emit Repay(msg.sender, 0, 0);
        }
    }

    function repayAll() external onlyBorrower returns (uint256 repaidAmount) {
        accureInterest();
        repaidAmount = debt();
        if (repaidAmount != 0) {
            repay(repaidAmount);
        } else {
            emit Repay(msg.sender, 0, 0);
        }
    }

    function repay(uint256 amount) public onlyBorrower {
        require(amount > 0);

        accureInterest();

        TransferHelper.safeTransferFrom(want, msg.sender, address(this), amount);

        require(IERC20(want).balanceOf(address(this)) >= amount);

        uint256 perfFee;
        if (borrowedInterest >= amount) {
            borrowedInterest = borrowedInterest - amount;
            perfFee = (amount * perfRate) / 10000;
        } else {
            perfFee = (borrowedInterest * perfRate) / 10000;
            borrowedPrincipal = borrowedPrincipal - (amount - borrowedInterest);
            borrowedInterest = 0;
        }
        TransferHelper.safeTransfer(want, treasury, perfFee);
        uint256 amountRepaid = amount - perfFee;

        TransferHelper.safeApprove(want, address(superChargerVault), amountRepaid);
        uint256 beforeBalance = IERC20(want).balanceOf(address(this));
        superChargerVault.repayFromLendingManager(amountRepaid);
        uint256 afterBalance = IERC20(want).balanceOf(address(this));
        require(beforeBalance - afterBalance == amountRepaid, "WooLendingManager: REPAY_AMOUNT_ERROR");

        emit Repay(msg.sender, amount, perfFee);
    }

    function inCaseTokenGotStuck(address stuckToken) external onlyOwner {
        if (stuckToken == ETH_PLACEHOLDER_ADDR) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        } else {
            uint256 amount = IERC20(stuckToken).balanceOf(address(this));
            TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "../interfaces/IWETH.sol";
import "../interfaces/IWooAccessManager.sol";

import "../libraries/TransferHelper.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract WooWithdrawManagerV2 is Ownable, ReentrancyGuard {
    // addedAmount: added withdrawal amount for this user
    // totalAmount: total withdrawal amount for this user
    event WithdrawAdded(address indexed user, uint256 addedAmount, uint256 totalAmount);

    event Withdraw(address indexed user, uint256 amount);

    address public want;
    address public weth;
    address public accessManager;
    address public superChargerVault;

    mapping(address => uint256) public withdrawAmount;

    address constant ETH_PLACEHOLDER_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor() {}

    function init(
        address _weth,
        address _want,
        address _accessManager,
        address _superChargerVault
    ) external onlyOwner {
        weth = _weth;
        want = _want;
        accessManager = _accessManager;
        superChargerVault = _superChargerVault;
    }

    modifier onlyAdmin() {
        require(
            owner() == msg.sender || IWooAccessManager(accessManager).isVaultAdmin(msg.sender),
            "WooWithdrawManager: !owner"
        );
        _;
    }

    modifier onlySuperChargerVault() {
        require(superChargerVault == msg.sender, "WooWithdrawManager: !superChargerVault");
        _;
    }

    function setSuperChargerVault(address _superChargerVault) external onlyAdmin {
        superChargerVault = _superChargerVault;
    }

    function addWithdrawAmount(address user, uint256 amount) external onlySuperChargerVault {
        // NOTE: in V2, granular token transfer is avoided to save the gas consumption;
        // Do remember batch transfer the total amount of `want` tokens after calling this method.

        // TransferHelper.safeTransferFrom(want, msg.sender, address(this), amount);
        withdrawAmount[user] = withdrawAmount[user] + amount;
        emit WithdrawAdded(user, amount, withdrawAmount[user]);
    }

    function withdraw() external nonReentrant {
        uint256 amount = withdrawAmount[msg.sender];
        if (amount == 0) {
            return;
        }
        withdrawAmount[msg.sender] = 0;
        if (want == weth) {
            IWETH(weth).withdraw(amount);
            TransferHelper.safeTransferETH(msg.sender, amount);
        } else {
            TransferHelper.safeTransfer(want, msg.sender, amount);
        }
        emit Withdraw(msg.sender, amount);
    }

    function inCaseTokenGotStuck(address stuckToken) external onlyOwner {
        require(stuckToken != want);
        if (stuckToken == ETH_PLACEHOLDER_ADDR) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        } else {
            uint256 amount = IERC20(stuckToken).balanceOf(address(this));
            TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
        emit Paused(_msgSender());
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
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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

pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewarder {
    event OnRewarded(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 oldRate, uint256 newRate);

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 unpaidRewards;
    }

    struct PoolInfo {
        uint256 accTokenPerShare;
        uint256 lastRewardBlock;
    }

    function onRewarded(address user, uint256 amount) external;

    function pendingTokens(address user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title Woo private pool for swap.
/// @notice Use this contract to directly interfact with woo's synthetic proactive
///         marketing making pool.
/// @author woo.network
interface IWooPPV2 {
    /* ----- Events ----- */

    event Deposit(address indexed token, address indexed sender, uint256 amount);
    event Withdraw(address indexed token, address indexed receiver, uint256 amount);
    event Migrate(address indexed token, address indexed receiver, uint256 amount);
    event AdminUpdated(address indexed addr, bool flag);
    event FeeAddrUpdated(address indexed newFeeAddr);
    event WooracleUpdated(address indexed newWooracle);
    event WooSwap(
        address indexed fromToken,
        address indexed toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address from,
        address indexed to,
        address rebateTo,
        uint256 swapVol,
        uint256 swapFee
    );

    /* ----- External Functions ----- */

    /// @notice The quote token address (immutable).
    /// @return address of quote token
    function quoteToken() external view returns (address);

    /// @notice Gets the pool size of the specified token (swap liquidity).
    /// @param token the token address
    /// @return the pool size
    function poolSize(address token) external view returns (uint256);

    /// @notice Query the amount to swap `fromToken` to `toToken`, without checking the pool reserve balance.
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of `fromToken` to swap
    /// @return toAmount the swapped amount of `toToken`
    function tryQuery(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view returns (uint256 toAmount);

    /// @notice Query the amount to swap `fromToken` to `toToken`, with checking the pool reserve balance.
    /// @dev tx reverts when 'toToken' balance is insufficient.
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of `fromToken` to swap
    /// @return toAmount the swapped amount of `toToken`
    function query(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view returns (uint256 toAmount);

    /// @notice Swap `fromToken` to `toToken`.
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of `fromToken` to swap
    /// @param minToAmount the minimum amount of `toToken` to receive
    /// @param to the destination address
    /// @param rebateTo the rebate address (optional, can be address ZERO)
    /// @return realToAmount the amount of toToken to receive
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address to,
        address rebateTo
    ) external returns (uint256 realToAmount);

    /// @notice Deposit the specified token into the liquidity pool of WooPPV2.
    /// @param token the token to deposit
    /// @param amount the deposit amount
    function deposit(address token, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}