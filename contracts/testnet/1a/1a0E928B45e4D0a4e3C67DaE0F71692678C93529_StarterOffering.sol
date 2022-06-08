// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../utils/SafeMath.sol";
import "./../utils/TransferV1.sol";
import "./../utils/Caller.sol";
import "./../config/IConfig.sol";
import "./IStarterOffering.sol";

contract StarterOffering is IStarterOffering, Caller {
    using SafeMath for uint256;

    IConfig public config;
    mapping(uint256 => Offering) public offeringInfo;
    mapping(uint256 => mapping(address => uint256)) public pledgeAmount;
    mapping(uint256 => address[]) public pledgeAddress;

    constructor(IConfig config_) {
        _setConfig(config_);
    }

    function setConfig(IConfig config_) external onlyCaller {
        _setConfig(config_);
    }

    function _setConfig(IConfig config_) private {
        config = config_;
    }

    function makeOffering(
        uint256 offeringId,
        address offeringToken,
        uint128 offeringAmount,
        address pledgeToken,
        uint256 expectAmount,
        uint256 pledgeLimit,
        uint256 exchangeRate,
        uint128 pledgeStart,
        uint128 payStart,
        uint128 lockStart,
        uint128 lockEnd
    ) external override {
        require(
            0 < pledgeStart &&
                pledgeStart < payStart &&
                payStart < lockStart &&
                lockStart < lockEnd,
            "1142"
        );
        require(address(0) != offeringToken && 0 < offeringAmount, "1144");
        require(0 < pledgeLimit, "1152");
        offeringInfo[offeringId] = Offering(
            offeringToken,
            offeringAmount,
            pledgeToken,
            0,
            expectAmount,
            pledgeLimit,
            exchangeRate,
            0,
            pledgeStart,
            payStart,
            lockStart,
            lockEnd
        );
    }

    function setParam(
        uint256 offeringId,
        uint256 expectAmount_,
        uint256 pledgeLimit_
    ) external override onlyCaller {
        Offering storage offering = offeringInfo[offeringId];
        require(1 <= offering.state, "1120");
        require(0 < pledgeLimit_, "1152");
        offering.expectAmount = expectAmount_;
        offering.pledgeLimit = pledgeLimit_;
    }

    function setparam2(
        uint256 offeringId,
        uint128 pledgeStart_,
        uint128 payStart_,
        uint128 lockStart_,
        uint128 lockEnd_
    ) external override onlyCaller {
        Offering storage offering = offeringInfo[offeringId];
        require(0 == offering.state, "1120");

        offering.pledgeStart = pledgeStart_;
        offering.payStart = payStart_;
        offering.lockStart = lockStart_;
        offering.lockEnd = lockEnd_;
    }

    function updateState(uint256 offeringId) external override {
        //判断状态
        Offering storage offering = offeringInfo[offeringId];
        uint256 currentNum = block.number;
        if (0 == offering.state) {
            if (currentNum > offering.payStart) {
                offering.state = 1;
            }
        } else if (1 == offering.state) {
            if (currentNum > offering.lockStart) {
                offering.state = 2;
            }
        } else if (2 == offering.state) {
            if (currentNum > offering.lockEnd) {
                offering.state = 3;
            }
        }
    }

    function pledge(uint256 offeringId, uint256 amount)
        external
        payable
        override
    {
        //判断状态
        Offering storage offering = offeringInfo[offeringId];
        require(1 == offering.state, "1120");
        //判断质押限制
        uint256 personPledgedAmount = pledgeAmount[offeringId][msg.sender];
        require(offering.pledgeLimit >= personPledgedAmount + amount, "1121");
        if (0 == personPledgedAmount) {
            address[] storage addressArry = pledgeAddress[offeringId];
            addressArry.push(msg.sender);
        }
        //增加个人质押数量和总数量
        pledgeAmount[offeringId][msg.sender] = personPledgedAmount.add(
            amount,
            "1123"
        );
        offering.pledgedAmount = offering.pledgedAmount.add(amount, "1123");
        //转账到assert合约
        TransferV1.transferFromFlush(
            config.getApproveProxy(),
            offering.pledgeToken,
            msg.sender,
            address(config.getAsset()),
            amount,
            "1194",
            "1196"
        );

        //触发事件
        emit PledgeEvent(offeringId, msg.sender, amount, block.timestamp);
    }

    function unPledge(uint256 offeringId, uint256 unPledgedAmount)
        external
        payable
        override
    {
        //判断状态 质押期和锁仓期都可以解押
        Offering storage offering = offeringInfo[offeringId];
        require(0 < offering.state && 3 > offering.state, "1120");
        //判断解押数量小于等于已质押数量
        uint256 personPledgedAmount = pledgeAmount[offeringId][msg.sender];
        require(unPledgedAmount <= personPledgedAmount, "1121");

        //减去个人质押数量和总数量
        pledgeAmount[offeringId][msg.sender] = personPledgedAmount.sub(
            unPledgedAmount,
            "1123"
        );
        offering.pledgedAmount = offering.pledgedAmount.sub(
            unPledgedAmount,
            "1123"
        );

        //从资产托管合约转账用户地址
        config.getAsset().claimMainOrERC20(
            offering.pledgeToken,
            msg.sender,
            unPledgedAmount
        );

        //触发事件
        emit UnPledgeEvent(
            offeringId,
            msg.sender,
            unPledgedAmount,
            block.timestamp
        );
    }

    //手动领取
    function receiveToken(uint256 offeringId) external payable override {
        //判断状态
        Offering storage offering = offeringInfo[offeringId];
        require(3 == offering.state, "1171");

        (
            uint256 personOfferingAmount,
            uint256 surplusPladgeAmount
        ) = _getOfferingTokenAmount(offeringId, offering, msg.sender);
        //转账打新代币
        config.getAsset().claimMainOrERC20(
            offering.offeringToken,
            msg.sender,
            personOfferingAmount
        );

        //如果有剩余质押代币，返还用户
        if (0 < surplusPladgeAmount) {
            //转账打新代币
            config.getAsset().claimMainOrERC20(
                offering.pledgeToken,
                msg.sender,
                surplusPladgeAmount
            );
        }
    }

    //自动领取
    function autoReceiveToken(uint256 offeringId) external payable override {
        //判断状态
        Offering storage offering = offeringInfo[offeringId];
        require(3 == offering.state, "1171");
        address[] storage currentPledgeAddress = pledgeAddress[offeringId];
        uint256 personOfferingAmount;
        uint256 surplusPladgeAmount;
        for (uint8 i = 0; i < currentPledgeAddress.length; i++) {
            address add = currentPledgeAddress[i];
            (
                personOfferingAmount,
                surplusPladgeAmount
            ) = _getOfferingTokenAmount(offeringId, offering, add);
            //转账打新代币
            config.getAsset().claimMainOrERC20(
                offering.offeringToken,
                msg.sender,
                personOfferingAmount
            );

            //如果有剩余质押代币，返还用户
            if (0 < surplusPladgeAmount) {
                //转账质押代币
                config.getAsset().claimMainOrERC20(
                    offering.pledgeToken,
                    msg.sender,
                    surplusPladgeAmount
                );
            }
        }
        //剩余质押币转给管理员账户
        config.getAsset().claimMainOrERC20(
            offering.pledgeToken,
            config.getAddressByUint256(10011),
            IERC20(offering.pledgeToken).balanceOf(address(config.getAsset()))
        );
    }

    function _getOfferingTokenAmount(
        uint256 offeringId,
        Offering memory offering,
        address account
    ) private returns (uint256, uint256) {
        uint256 personOfferingAmount;
        uint256 surplusPladgeAmount;
        uint256 personPledgedAmount = pledgeAmount[offeringId][account];
        //如果质押的比预期的少
        if (offering.expectAmount > offering.pledgedAmount) {
            //按照兑换比例计算
            personOfferingAmount = personPledgedAmount.mul(10**18, "1190").div(
                offering.exchangeRate,
                "1182"
            );
            surplusPladgeAmount = 0;
        } else {
            //按照质押占比计算
            personOfferingAmount = personPledgedAmount
                .mul(offering.offeringAmount, "1183")
                .div(offering.pledgedAmount, "1184"); //个人得到的打新币数量

            uint256 used = personOfferingAmount
                .mul(offering.exchangeRate, "1186")
                .div(10**18, "1193");
            surplusPladgeAmount = personPledgedAmount - used;
        }
        delete pledgeAmount[offeringId][account];
        return (personOfferingAmount, surplusPladgeAmount);
    }

    function getOffering(uint256 offeringId, address account)
        external
        view
        override
        returns (
            uint256[] memory,
            uint8,
            uint128,
            uint128,
            uint128,
            uint128
        )
    {
        Offering storage offering = offeringInfo[offeringId];
        uint256 personPledgeAmount = pledgeAmount[offeringId][account];
        uint256[] memory amountArray = new uint256[](7);
        amountArray[0] = personPledgeAmount;
        amountArray[1] = offering.offeringAmount;
        amountArray[2] = offering.offeringAmount;
        amountArray[3] = offering.expectAmount;
        amountArray[4] = offering.pledgeLimit;
        amountArray[5] = offering.exchangeRate;
        return (
            amountArray,
            offering.state,
            offering.pledgeStart,
            offering.payStart,
            offering.lockStart,
            offering.lockEnd
        );
    }

    function getOfferingV2(uint256 offeringId)
        external
        view
        override
        returns (Offering memory)
    {
        Offering memory offering = offeringInfo[offeringId];

        return offering;
    }

    function getAccountPledgedAmount(uint256 offeringId, address account)
        external
        view
        override
        returns (uint256)
    {
        uint256 personPledgeAmount = pledgeAmount[offeringId][account];
        return personPledgeAmount;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

pragma solidity 0.8.1;

// 数学安全库
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            require(c >= a, errorMessage);
            return c;
        }
    }

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

    function mul(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            if (a == 0) return 0;
            uint256 c = a * b;
            require(c / a == b, errorMessage);
            return c;
        }
    }

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

pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../proxy/IApproveProxy.sol";

// 安全转账库
library TransferV1 {
    using SafeERC20 for IERC20;

    function transfer_(
        address token,
        address to,
        uint256 amount
    ) internal {
        if (0 < amount) {
            if (address(0) == token) {
                (bool success, ) = to.call{value: amount}(new bytes(0));
                require(success, "1052");
            } else {
                IERC20(token).safeTransfer(to, amount);
            }
        }
    }

    function transferFromStandard(
        IApproveProxy approveProxy,
        address token,
        address from,
        address to,
        uint256 amount,
        string memory errorMessage0,
        string memory errorMessage1
    ) internal {
        if (0 < amount) {
            if (address(0) == token) {
                require(amount <= msg.value, errorMessage0);
                (bool success, ) = to.call{value: amount}(new bytes(0));
                require(success, errorMessage1);
            } else {
                approveProxy.transferFromERC20(token, from, to, amount);
            }
        }
    }

    function transferFromFlush(
        IApproveProxy approveProxy,
        address token,
        address from,
        address to,
        uint256 amount,
        string memory errorMessage0,
        string memory errorMessage1
    ) internal {
        if (address(0) == token) {
            require(amount <= msg.value, errorMessage0);
            if (0 < msg.value) {
                (bool success, ) = to.call{value: msg.value}(new bytes(0));
                require(success, errorMessage1);
            }
        } else {
            approveProxy.transferFromERC20(token, from, to, amount);
            if (0 < msg.value) {
                (bool success, ) = to.call{value: msg.value}(new bytes(0));
                require(success, errorMessage1);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";

// 调用者
contract Caller is Ownable {
    bool private init;
    mapping(address => bool) public caller;

    modifier onlyCaller() {
        require(caller[msg.sender], "1049");
        _;
    }

    function initOwner(address owner, address caller_) external {
        require(address(0) == Ownable.owner() && !init, "1102");
        init = true;
        _transferOwnership(owner);
        caller[caller_] = true;
    }

    function setCaller(address account, bool state) external onlyOwner {
        if (state) {
            caller[account] = state;
        } else {
            delete caller[account];
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./../proxy/IApproveProxy.sol";
import "./../list/IList.sol";
import "./../asset/IAsset.sol";

// 实现Config.sol
interface IConfig {
    // 资产授权合约，必须非0地址，非法要报错
    function getApproveProxy() external view returns (IApproveProxy);

    // 铸造的BoxToken NFT托管地址，必须是普通地址，必须非0地址，非法要报错
    function getMintBoxNFT() external view returns (address);

    // 燃烧地址，必须是普通地址，防止ERC721等某些币的特殊支持燃烧机制，必须非0地址，非法要报错
    function getBurn() external view returns (address);

    // 白名单合约，必须非0地址，非法要报错
    function getList() external view returns (IList);

    // 用户资产托管合约，必须非0地址，非法要报错
    function getAsset() external view returns (IAsset);

    // NFT默认平台创作者，必须是普通地址，必须非0地址，非法要报错
    function getNFTCreator() external view returns (address);

    // 盲盒售卖费地址，必须是普通地址，必须非0地址，非法要报错
    function getBoxSaleFee() external view returns (address);

    // NFT合成费地址，必须是普通地址，必须非0地址，非法要报错
    function getNFTComposeFee() external view returns (address);

    // NFT交易市场-平台费地址(必须是普通地址，必须非0地址)、平台费率(0<= x < 100)、创作者费率(0<= x < 100)，非法要报错
    function getNFTTradePlatformFeeAndPlatformFeeRateAndCreatorFeeRate()
        external
        view
        returns (
            uint256,
            address,
            uint256
        );

    function getAddressByAddress(address key) external view returns (address);

    function getUint256ByAddress(address key) external view returns (uint256);

    function getAddressByUint256(uint256 key) external view returns (address);

    function getUint256ByUint256(uint256 key) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

interface IStarterOffering {
    event PledgeEvent(
        uint256 indexed offeringId,
        address indexed account,
        uint256 indexed pledgeAmount,
        uint256 ts
    );

    event UnPledgeEvent(
        uint256 indexed offeringId,
        address indexed account,
        uint256 indexed unPledgeAmount,
        uint256 ts
    );

    struct Offering {
        //打新代币
        address offeringToken;
        //打新代币数量
        uint256 offeringAmount;
        //质押代币地址
        address pledgeToken;
        //已质押总数量
        uint256 pledgedAmount;
        //预期质押数量
        uint256 expectAmount;
        //质押限制
        uint256 pledgeLimit;
        //质押/打新  乘以10 ** 18
        uint256 exchangeRate;
        //状态  0：预热期；1：质押期；2：锁仓期；3：代币分配期
        uint8 state;
        //预热期开始区块
        uint128 pledgeStart;
        //质押期开始区块
        uint128 payStart;
        //锁仓期开始区块
        uint128 lockStart;
        //锁仓期结束区块
        uint128 lockEnd;
    }

    function makeOffering(
        uint256 offeringId,
        address offeringToken,
        uint128 offeringAmount,
        address pledgeToken,
        uint256 expectAmount,
        uint256 pledgeLimit,
        uint256 exchangeRate,
        uint128 pledgeStart,
        uint128 payStart,
        uint128 lockStart,
        uint128 lockEnd
    ) external;

    function setParam(
        uint256 offeringId,
        uint256 expectAmount_,
        uint256 pledgeLimit_
    ) external;

    function setparam2(
        uint256 offeringId,
        uint128 pledgeStart_,
        uint128 payStart_,
        uint128 lockStart_,
        uint128 lockEnd_
    ) external;

    function updateState(uint256 offeringId) external;

    function pledge(uint256 offeringId, uint256 amount) external payable;

    function unPledge(uint256 offeringId, uint256 unPledgedAmount)
        external
        payable;

    function receiveToken(uint256 offeringId) external payable;

    function autoReceiveToken(uint256 offeringId) external payable;

    function getOffering(uint256 offeringId, address account)
        external
        view
        returns (
            uint256[] memory,
            uint8,
            uint128,
            uint128,
            uint128,
            uint128
        );

    function getOfferingV2(uint256 offeringId)
        external
        view
        returns (Offering memory);

    function getAccountPledgedAmount(uint256 offeringId, address account)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

pragma solidity 0.8.1;

// 用户授权
// 因为有的合约未实现销毁接口，故不在这里实现代理销毁
interface IApproveProxy {
    function transferFromERC20(
        address token,
        address from,
        address to,
        uint256 amount
    ) external;

    function transferFromERC721(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

pragma solidity 0.8.1;

interface IList {
    function getStateV1(address account) external view returns (bool);

    function getStateV2(uint16 id, address account)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface IAsset {
    function claimMainOrERC20(
        address token,
        address to,
        uint256 amount
    ) external;

    function claimERC721(
        address token,
        address to,
        uint256 tokenId
    ) external;
}