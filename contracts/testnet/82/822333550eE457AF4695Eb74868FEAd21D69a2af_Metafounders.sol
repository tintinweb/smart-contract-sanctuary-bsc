// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./factory/SuperAdmin.sol";
import "./factory/Ambassador.sol";
import "./factory/VIP.sol";
import "./factory/WhiteListTokens.sol";
import "./factory/Bonus.sol";

import "./security/ReEntrancyGuard.sol";
import "./helpers/Oracle.sol";
import "./helpers/Withdraw.sol";

import "./Interfaces/ITransactions.sol";

// import "./Interfaces/IPropertyToken.sol";

contract Metafounders is SuperAdmin, VIP, ReEntrancyGuard, Bonus, Withdraw {
    /// @dev SafeMath library
    using SafeMath for uint256;

    /// @dev Stack too deep,

    /**
     * @notice SlotInfo data struct
     * @dev SlotInfo data struct
     * @param _amountTokens                                     Amount of tokens sent
     * @param _admin
     * @param _buyed                                            Buyed wallet address
     * @param _token                                            Token Address used to join
     */
    struct SlotInfo {
        uint _amountTokens;
        bool _admin;
        address _buyed;
        address _token;
        string _usernameVip;
    }

    /// @dev Contract Fee
    uint256 public fee = 300;

    /**
     * @dev Update Contract Fee
     * @param _fee                                              Fee Amount at BasicPoint
     */
    function setFee(uint256 _fee) external onlyUser {
        fee = _fee;
    }

    /**
     * @notice join normal token to the contract
     * @dev join normal token to the contract
     * @param _username                                         VIP Username
     * @param _token                                            Token Address used to join
     * @param _amountTokens                                     Amount of tokens sent
     * @param _wallet                                           Host wallet address
     * @param _type                                             NFT type (1 - normal, 2 - ambassador, 3 - vip)
     * @param _username                                         Username of Host
     */
    function joinWithToken(
        string memory _usernameVip,
        address _token,
        uint256 _amountTokens,
        address _wallet,
        uint256 _type,
        string memory _username
    ) external noReentrant {

        /**
         * ===============================================
         * @dev Package Validations
         * ===============================================
         */
        require(
            validateBuyBonusPackage(_type, _token, _amountTokens),
            "Join With Token: Invalid payment order"
        );

        /**
         * ===============================================
         * @dev Get WhiteList Contract Service
         * ===============================================
         */
        require(
            validateWhiteListToken(_token, false),
            "Join With Token: Invalid token"
        );

        /// @dev  Check that the user's token balance is enough to do the swap
        require(
            IERC20(_token).balanceOf(_msgSender()) >= _amountTokens,
            "Join With Token: Your balance is lower than the amount of tokens you want to sell"
        );

        /// @dev allowonce to execute the swap
        require(
            IERC20(_token).allowance(_msgSender(), address(this)) >=
                _amountTokens,
            "Join With Token: You don't have enough tokens to buy"
        );

        /// @dev Transfer token at SC
        require(
            IERC20(_token).transferFrom(
                _msgSender(),
                address(this),
                _amountTokens
            ),
            "Join With Token: Failed to transfer tokens from user to vendor"
        );

        _joinWithToken(
            _usernameVip,
            _msgSender(),
            _token,
            _amountTokens,
            _wallet,
            _type,
            _username
        );
    }

    /**
     * @notice Join with Regular Token
     * @dev Join with Regular Token
     * @param _usernameVip                                      VIP Username
     * @param _buyed                                            Buyed wallet address
     * @param _token                                            Token Address used to join
     * @param _amountTokens                                     Amount of tokens sent
     * @param _wallet                                           Host wallet address
     * @param _type                                             NFT type (1 - normal, 2 - ambassador, 3 - vip)
     * @param _username                                         Username of Host
     */
    function _joinWithToken(
        string memory _usernameVip,
        address _buyed,
        address _token,
        uint256 _amountTokens,
        address _wallet,
        uint256 _type,
        string memory _username
    ) internal {
        /// @dev Save request at SlotInfo and set values
        SlotInfo memory slot;
        slot._amountTokens = _amountTokens;
        slot._buyed = _buyed;
        slot._token = _token;
        slot._usernameVip = _usernameVip;

        /**
         * ===============================================
         * @dev Store in memory contract values
         * ===============================================
         */
        uint256 _comissionAmbassadorPercent = comissionAmbassador;
        uint256 _contractFee = fee;

        /// @dev Wallet Address of createdBy field for VIP
        address walletAmbassador = address(0);

        /// @dev Invited by VIP
        if (_wallet != address(0)) {
            /// @dev Get VIP data
            VipStruct memory _vip = getVip(_username, _wallet);

            /// @dev Check if VIP is available
            require(_vip.active, "Join With Token: The user is not a VIP");

            // -----------------------VIP  (bono directo)-------------------------------------
            /**
             * ===============================================
             * @dev Pay COMISSIONDIRECTPAYBONUS
             * ===============================================
             */

            /// @dev Calculate comission direct pay bonus
            uint _directPayBonus = calculatePercentage(
                slot._amountTokens,
                comissionDirectPayBonus
            );

            /// @dev Calculate contract Fee
            uint256 _contractFeeDirectBonus = calculatePercentage(
                _directPayBonus,
                _contractFee
            );

            /// @dev Send VIP commission
            transferToken(
                slot._token,
                _vip.addr,
                _directPayBonus.sub(_contractFeeDirectBonus)
            );

            /// @dev Save VIP commission log
            ITransactions(transactionContractService)._storeVIPLog(
                slot._token,
                _vip.addr,
                slot._buyed,
                _directPayBonus.sub(_contractFeeDirectBonus),
                slot._amountTokens
            );

            // -----------------------Ambassador (bono referido)-------------------------------------
            /**
             * ===============================================
             * @dev Pay COMISSIONAMBASSADOR
             * ===============================================
             */

            ///  @dev Get Ambassador data
            AmbassadorStruct memory ambassador = getAmbassador(
                "",
                _vip.addressAmbassador
            );

            /**
             * @dev Send Direct Bonus if Ambassador is available
             * - Send token to the Ambassador
             * - Store transaction log from Ambassador
             */
            if (ambassador.addr != address(0)) {

                /// @dev send comission to the contract ambassador
                uint _comissionAmbassador = calculatePercentage(
                    slot._amountTokens,
                    _comissionAmbassadorPercent
                );

                /// @dev Calculate contract Fee
                uint256 _contractFeeBonusAmbassador = calculatePercentage(
                    _comissionAmbassador,
                    _contractFee
                );

                /// @dev send token to the sender
                /// @dev proceso de distribucion de bonos
                sendComissionAmbassador(
                    ambassador,
                    slot._token,
                    _comissionAmbassador.sub(_contractFeeBonusAmbassador),
                    slot._amountTokens,
                    false
                );
            }

            /// @dev wallet ambassador
            walletAmbassador = _vip.addressAmbassador;

            /// @dev Invited by Ambassador
        } else {
            // -----------------------Ambassador (bono directo)-------------------------------------
            /**
             * ===============================================
             * @dev Pay COMISSIONDIRECTPAYBONUS
             * ===============================================
             */

            ///  @dev Get Ambassador data
            AmbassadorStruct memory ambassador = getAmbassador(
                _username,
                _wallet
            );

            /**
             * @dev Send Direct Bonus if Ambassador is available
             * - Send token to the Ambassador
             * - Store transaction log from Ambassador
             */
            if (ambassador.addr != address(0)) {

                /// @dev Calculate Direct Bonus to pay at Ambassador
                uint256 _directPayBonus = calculatePercentage(
                    slot._amountTokens,
                    comissionDirectPayBonus
                );

                /// @dev Calculate contract Fee over Ambassador Commission
                uint256 _contractFeeDirectBonus = calculatePercentage(
                    _directPayBonus,
                    _contractFee
                );

                /// @dev Send Direct Bonus
                transferToken(
                    slot._token,
                    ambassador.addr,
                    _directPayBonus.sub(_contractFeeDirectBonus)
                );

                /// @dev Save Direct Bonus log
                ITransactions(transactionContractService)._storeAmbassadorLog(
                    slot._token,
                    ambassador.addr,
                    slot._buyed,
                    _directPayBonus.sub(_contractFeeDirectBonus),
                    0
                );
            }

            /// -----------------------Ambassador (bono de referido)-------------------------------------
            /**
             * ===============================================
             * @dev Pay COMISSIONAMBASSADOR
             * ===============================================
             */

            /**
             * @dev Send Comission Ambassador if Ambassador is available
             * - Send token to the Ambassador
             * - Store transaction log from Ambassador
             */
            if (ambassador.addr != address(0)) {

                /// @dev send comission to the contract ambassador
                uint _comissionAmbassador = calculatePercentage(
                    slot._amountTokens,
                    _comissionAmbassadorPercent
                );

                /// @dev Calculate contract Fee
                uint256 _contractFeeBonusAmbassador = calculatePercentage(
                    _comissionAmbassador,
                    _contractFee
                );

                /// @dev send token to the sender
                /// @dev proceso de distribucion de bonos
                sendComissionAmbassador(
                    ambassador,
                    slot._token,
                    _comissionAmbassador.sub(_contractFeeBonusAmbassador),
                    slot._amountTokens,
                    false
                );
            }

            /// @dev wallet ambassador
            walletAmbassador = ambassador.addr;
        }

        // -----------------------Admin-------------------------------------
        /**
         * ===============================================
         * @dev Pay COMISSIONADMIN
         * ===============================================
         */

        /// @dev Calculate Admin Commission
        uint _comissionAdmin = calculatePercentage(
            slot._amountTokens,
            comissionAdmin
        );

        /// @dev Share Commission betweens Admins
        sendComissionAdmin(2, slot._buyed, false, slot._token, _comissionAdmin, slot._amountTokens);

        // -----------------------SuperAdmin-------------------------------------
        /**
         * ===============================================
         * @dev Pay COMISSIONADMIN
         * ===============================================
         */

        /// @dev Calculate SuperAdmin Commission
        uint _comissionSuperAdmin = calculatePercentage(
            slot._amountTokens,
            comissionSuperAdmin
        );

        /// @dev Share Commission betweens SuperAdmins
        sendComissionAdmin(1, slot._buyed, false, slot._token, _comissionSuperAdmin, slot._amountTokens);

        // -----------------------Envio de NFT-------------------------------------
        /**
         * ===============================================
         * @dev Send NFT
         * ===============================================
         */

        /// @dev Send nft token to the user
        sendNft(_type, slot._buyed);

        // -----------------------Registro de VIP Si NO EXISTE-------------------------------------
        /**
         * ===============================================
         * @dev Register VIP if not exists
         * ===============================================
         */

        /// @dev Get VIP data
        VipStruct memory vip = getVip("", slot._buyed);

        /// @dev Check if VIP doesn't registered - Store VIP record
        if (vip.addr == address(0)) {
            /// @dev Generate VIP username

            /// @dev Store VIP record
            _registerVIP(walletAmbassador, slot._buyed, slot._usernameVip, true);
        }
    }

    function joinWithTokenNative(
        string memory _usernameVip,
        address _token,
        address _wallet,
        uint _type,
        string memory _username
    ) external payable noReentrant {

        /**
         * ===============================================
         * @dev Package Validations
         * ===============================================
         */
        require(
            validateBuyBonusPackage(_type, _token, msg.value),
            "Join With Token: Invalid payment order"
        );

        /**
         * ===============================================
         * @dev Get WhiteList Contract Service
         * ===============================================
         */
        require(
            validateWhiteListToken(_token, true),
            "Join With Token: Invalid token"
        );

        _joinWithTokenNative(
            _usernameVip,
            _token, 
            _wallet, 
            _type,
            _username
        );
    }

    /**
     * @notice Join with Native Token
     * @dev Join with Native Token
     * @param _username                                         VIP Username
     * @param _token                                            Token Address used to join
     * @param _wallet                                           Host wallet address
     * @param _type                                             NFT type (1 - normal, 2 - ambassador, 3 - vip)
     * @param _username                                         Username of Host
     */
    function _joinWithTokenNative(
        string memory _usernameVip,
        address _token,
        address _wallet,
        uint _type,
        string memory _username
    ) internal {
        /// @dev Save request at SlotInfo and set values
        SlotInfo memory slot;
        slot._token = _token;
        slot._usernameVip = _usernameVip;

        /**
         * ===============================================
         * @dev Store in memory contract values
         * ===============================================
         */
        uint256 _comissionAmbassadorPercent = comissionAmbassador;
        uint256 _contractFee = fee;

        /// @dev Wallet Address of createdBy field for VIP
        address walletAmbassador = address(0);

        /// @dev Invited by VIP
        if (_wallet != address(0)) {
            /// @dev Get VIP data
            VipStruct memory _vip = getVip(_username, _wallet);

            /// @dev Check if VIP is available
            require(_vip.active, "Join With Token: The user is not a VIP");

            // -----------------------VIP  (bono directo)-------------------------------------
            /**
             * ===============================================
             * @dev Pay COMISSIONDIRECTPAYBONUS
             * ===============================================
             */

            //// @dev send comission to the contract vip
            uint _directPayBonus = calculatePercentage(
                msg.value,
                comissionDirectPayBonus
            );

            /// @dev Calculate contract Fee
            uint256 _contractFeeDirectBonus = calculatePercentage(
                _directPayBonus,
                _contractFee
            );

            /// @dev Send VIP commission
            transferNative(
                _vip.addr,
                _directPayBonus.sub(_contractFeeDirectBonus)
            );

            /// @dev Save VIP commission log
            ITransactions(transactionContractService)._storeVIPLog(
                slot._token,
                _vip.addr,
                _msgSender(),
                _directPayBonus.sub(_contractFeeDirectBonus),
                msg.value
            );

            // -----------------------Ambassador (bono referido)-------------------------------------
            /**
             * ===============================================
             * @dev Pay COMISSIONAMBASSADOR
             * ===============================================
             */

            ///  @dev Get Ambassador data
            AmbassadorStruct memory ambassador = getAmbassador(
                "",
                _vip.addressAmbassador
            );

            /**
             * @dev Send Direct Bonus if Ambassador is available
             * - Send token to the Ambassador
             * - Store transaction log from Ambassador
             */
            if (ambassador.addr != address(0)) {

                //// @dev send comission to the contract ambassador
                uint _comissionAmbassador = calculatePercentage(
                    msg.value,
                    _comissionAmbassadorPercent
                );

                /// @dev Calculate contract Fee
                uint256 _contractFeeBonusAmbassador = calculatePercentage(
                    _comissionAmbassador,
                    _contractFee
                );

                /// @dev send token to the sender
                /// @dev proceso de distribucion de bonos
                sendComissionAmbassador(
                    ambassador,
                    slot._token,
                    _comissionAmbassador.sub(_contractFeeBonusAmbassador),
                    msg.value,
                    true
                );

                /// @dev Save Direct Bonus log
                ITransactions(transactionContractService)._storeAmbassadorLog(
                    slot._token,
                    _vip.addressAmbassador,
                    _msgSender(),
                    _comissionAmbassador.sub(_contractFeeBonusAmbassador),
                    msg.value
                );
            }

            /// @dev wallet ambassador
            walletAmbassador = _vip.addressAmbassador;

        /// @dev Invited by Ambassador
        } else {
            // -----------------------Ambassador (bono directo)-------------------------------------
            /**
             * ===============================================
             * @dev Pay COMISSIONDIRECTPAYBONUS
             * ===============================================
             */

            ///  @dev Get Ambassador data
            AmbassadorStruct memory ambassador = getAmbassador(
                _username,
                _wallet
            );

            /**
             * @dev Send Direct Bonus if Ambassador is available
             * - Send token to the Ambassador
             * - Store transaction log from Ambassador
             */
            if (ambassador.addr != address(0)) {

                /// @dev Calculate Direct Bonus to pay at Ambassador
                uint _directPayBonus = calculatePercentage(
                    msg.value,
                    comissionDirectPayBonus
                );

                /// @dev Calculate contract Fee over Ambassador Commission
                uint256 _contractFeeDirectBonus = calculatePercentage(
                    _directPayBonus,
                    _contractFee
                );

                /// @dev Send Direct Bonus
                transferNative(
                    ambassador.addr,
                    _directPayBonus.sub(_contractFeeDirectBonus)
                );

                /// @dev Save Direct Pay Bonus log
                ITransactions(transactionContractService)._storeAmbassadorLog(
                    slot._token,
                    ambassador.addr,
                    _msgSender(),
                    _directPayBonus.sub(_contractFeeDirectBonus),
                    0
                );
            }

            // -----------------------Ambassador (bono de referido)-------------------------------------
            /**
             * ===============================================
             * @dev Pay COMISSIONAMBASSADOR
             * ===============================================
             */

            /**
             * @dev Send Comission Ambassador if Ambassador is available
             * - Send token to the Ambassador
             * - Store transaction log from Ambassador
             */
            if (ambassador.addr != address(0)) {

                /// @dev send comission to the contract ambassador
                uint _comissionAmbassador = calculatePercentage(
                    msg.value,
                    _comissionAmbassadorPercent
                );

                /// @dev Calculate contract Fee
                uint256 _contractFeeBonusAmbassador = calculatePercentage(
                    _comissionAmbassador,
                    _contractFee
                );

                /// @dev send token to the sender
                /// @dev proceso de distribucion de bonos
                sendComissionAmbassador(
                    ambassador,
                    slot._token,
                    _comissionAmbassador.sub(_contractFeeBonusAmbassador),
                    msg.value,
                    true
                );

            }

            /// @dev wallet ambassador
            walletAmbassador = ambassador.addr;
        }

        // -----------------------Admin-------------------------------------
        /**
         * ===============================================
         * @dev Pay COMISSIONADMIN
         * ===============================================
         */

        uint _comissionAdmin = calculatePercentage(
            msg.value,
            comissionAdmin
        );

        /// @dev distribuir tokens de admin
        sendComissionAdmin(2, _msgSender(), true, slot._token, _comissionAdmin, msg.value);

        // -----------------------SuperAdmin-------------------------------------
        /**
         * ===============================================
         * @dev Pay COMISSIONADMIN
         * ===============================================
         */

        /// @dev Calculate SuperAdmin Commission
        uint _comissionSuperAdmin = calculatePercentage(
            msg.value,
            comissionSuperAdmin
        );

        /// @dev Share Commission betweens SuperAdmins
        sendComissionAdmin(1, _msgSender(), true, slot._token, _comissionSuperAdmin, msg.value);

        // -----------------------Envio de NFT-------------------------------------
        /**
         * ===============================================
         * @dev Send NFT
         * ===============================================
         */

        /// @dev Send nft token to the user
        sendNft(_type, _msgSender());

        // -----------------------Registro de VIP Si NO EXISTE-------------------------------------
        /**
         * ===============================================
         * @dev Register VIP if not exists
         * ===============================================
         */

        /// @dev Get VIP data
        VipStruct memory vip = getVip("", _msgSender());

        /// @dev Check if VIP doesn't registered - Store VIP record
        if (vip.addr == address(0)) {
            /// @dev Store VIP record
            _registerVIP(walletAmbassador, _msgSender(), slot._usernameVip
            , true);
        }
    }

    /**
     * @notice Send Ambassador Commission
     * @dev Send Ambassador Commission
     * @param _ambassado                                                    Ambassador struct data
     * @param _token                                                        Contract Token address
     * @param _amount                                                       Amount of tokens
     * @param _buyAmount                                                    Amount of tokens to buy
     * @param _isNative                                                     Token is native
     */
    function sendComissionAmbassador(
        AmbassadorStruct memory _ambassado,
        address _token,
        uint256 _amount,
        uint256 _buyAmount,
        bool _isNative
    ) internal {

        /// @dev Mythic Commission
        if (_ambassado._type == 1) {
            if (_isNative) {
                transferNative(_ambassado.addr, _amount);
            } else {
                transferToken(_token, _ambassado.addr, _amount);
            }

            /// @dev Save Mythic log transaction
            ITransactions(transactionContractService)._storeAmbassadorLog(
                _token,
                _ambassado.addr,
                _msgSender(),
                _amount,
                _buyAmount
            );

        /// @dev Share Legendary Commission with Mythic
        } else {
            /// @dev Legendary Commission Percentage
            uint _commissionLegendary = calculatePercentage(
                _amount,
                _ambassado.commission
            );

            /// @dev Mythic Commission Percentage
            uint _commissionMythic = _amount.sub(_commissionLegendary);

            if (_isNative) {
                /// @dev send Legendary Commission
                transferNative(_ambassado.addr, _commissionLegendary);

                /// @dev send Mythic Commission
                transferNative(_ambassado.createdBy, _commissionMythic);
            } else {
                /// @dev send Legendary Commission
                transferToken(_token, _ambassado.addr, _commissionLegendary);

                /// @dev send Mythic Commission
                transferToken(_token, _ambassado.createdBy, _commissionMythic);
            }

            /// @dev Save Legendary log transaction
            ITransactions(transactionContractService)._storeAmbassadorLog(
                _token,
                _ambassado.addr,
                _msgSender(),
                _commissionLegendary,
                _buyAmount
            );

            /// @dev Save Mythic log transaction
            ITransactions(transactionContractService)._storeAmbassadorLog(
                _token,
                _ambassado.createdBy,
                _msgSender(),
                _commissionMythic,
                _buyAmount
            );
        }

        return;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
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
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../Interfaces/ITransactions.sol";
import "../helpers/Utils.sol";

contract SuperAdmin is Utils {

    /// @dev SafeMath library
    using SafeMath for uint256;

    /**
     * @notice SuperAdmin data struct
     * @dev SuperAdmin data struct
     * @param _type                                             Type of the SuperAdmin (1: SuperAdmin, 2: Admin)
     * @param addr                                              Wallet addresss
     * @param commission                                        Percentage of commission
     * @param active                                            Document status
     * @param index                                             Index
     */
    struct SAStruct {
        uint _type;
        address addr;
        uint256 commission;
        bool active;
        uint256 index;
    }

    /// @dev Mapping of SuperAdmin
    mapping(uint256 => SAStruct) _SA;

    /// @dev Count of SuperAdmin
    uint256 public _SACount;


    /// @dev porcentage distribution of commission
    uint256 public percentageSuperAdmin; // in basic points
    uint256 public percentageAdmin; // in basic points

    uint256 public comissionDirectPayBonus = 1000; // 10 % of commission
    uint256 public comissionAmbassador = 1000; // 10% of commission
    uint256 public comissionAdmin = 2000; //  20% of commission
    uint256 public comissionSuperAdmin = 6000; // 60% of commission

    /**
     * @notice Constructor Method
     * @dev Constructor Method
     */
    constructor() {
        _SACount = 0;
        percentageSuperAdmin = 0;
        percentageAdmin = 0;
    }

    /**
     * @notice Valid porcentaje distribution
     * @dev Valid porcentaje distribution
     * @param _percentage                                           Porcentaje of distribution to assign
     * @param _percentageCurrent                                    Current porcentaje of distribution                                  
     * @return bool                                                 Result of te valiation
     */
    function validPercentage(
        uint256 _percentage, 
        uint256 _percentageCurrent
    ) public pure returns (bool) {
        require(
            _percentage + _percentageCurrent <= 10000,
            "Valid Porcentaje: Porcentaje must be between 0 and 100"
        );

        return true;
    }

    /**
     * @notice Register SuperAdmin
     * @dev Register SuperAdmin
     * @param _addr                                                 Wallet addresss    
     * @param _percentage                                           Porcentaje of distribution to assign
     * @param _active                                               Document status
     */
    function registerSuperAdmin(
        address _addr,
        uint _percentage,
        bool _active
    ) external {
        return _registerSuperAdmin(1, _addr, _percentage, _active);
    }

    /**
     * @notice Register Admin
     * @dev Register Admin
     * @param _addr                                                 Wallet addresss    
     * @param _percentage                                           Porcentaje of distribution to assign
     * @param _active                                               Document status
     */
    function registerAdmin(
        address _addr,
        uint256 _percentage,
        bool _active
    ) external {
        return _registerSuperAdmin(2, _addr, _percentage, _active);
    }

    // @dev edit data admin

    /**
     * @notice Edit SuperAdmin data struct
     * @dev Edit SuperAdmin data struct
     * @param _type                                                 Operation type
     * @param _id                                                   Id of the SuperAdmin
     * @param _addr                                                 Input wallet address
     * @param _commission                                           Input porcentaje of commission
     * @param _active                                               Input document status
     */
    function editAdmin(
        uint _type,
        uint _id,
        address _addr,
        uint256 _commission,
        bool _active
    ) external onlyAdminRoot {

        /// @dev Update document status
        if (_type == 1) {
            _SA[_id].active = _active;

        /// @dev SUB porcentage distribution SUPER ADMIN
        } else if (_type == 2) {
            _SA[_id].commission = _commission;
            percentageSuperAdmin = percentageSuperAdmin.sub(_commission);

        /// @dev ADD porcentage distribution SUPER ADMIN
        } else if (_type == 3) {
            _SA[_id].commission = _commission;
            percentageSuperAdmin = percentageSuperAdmin.add(_commission);

        /// @dev SUB porcentage distribution ADMIN
        } else if (_type == 4) {
            _SA[_id].commission = _commission;
            percentageAdmin = percentageAdmin.sub(_commission);

        /// @dev ADD porcentage distribution ADMIN
        } else if (_type == 5) {
            _SA[_id].commission = _commission;
            percentageAdmin = percentageAdmin.add(_commission);
        
        /// @dev Update SuperAdmin wallet address
        } else if (_type == 6) {

            /// @dev Get SuperAdmin data
            SAStruct memory superAdmin = getSuperAdmin(_addr);

            /// @dev Check new SuperAdmin wallet address is not registered
            require(
                superAdmin.addr == address(0)
                || superAdmin.addr != _SA[_id].addr,
                "editAdmin: New SuperAdmin wallet address is already registered"
            );

            _SA[_id].addr = _addr;
        }
    }

    /**
     * @notice Update Contract commission values
     * @dev Update Contract commission values
     * @param _id                                                   Operation type
     * @param _value                                                Input value to assign
     */
    function editValueComissionAdmin(
        uint8 _id, 
        uint256 _value
    ) external onlyAdminRoot {

        /// @dev Update Commission - Direct Pay Bonus
        if (_id == 1) {
            comissionDirectPayBonus = _value;
        
        //// @dev Update Commission - Ambassador
        } else if (_id == 2) {
            comissionAmbassador = _value;
        
        /// @dev Update Commission - Admin
        } else if (_id == 3) {
            comissionAdmin = _value;

        /// @dev Update Commission - SuperAdmin
        } else if (_id == 4) {
            comissionSuperAdmin = _value;
        }
    }


    /**
     * @notice Get SuperAdmin by wallet address
     * @dev Get SuperAdmin by wallet address
     * @param _addr                                                 Wallet address of the SuperAdmin
     * @return SAStruct                                             SuperAdmin data
     */
    function getSuperAdmin(
        address _addr
    ) public view returns (SAStruct memory){
        unchecked {
            for (uint256 i = 0; i < _SACount; i++) {
                if (_SA[i].addr == _addr) {
                    return _SA[i];
                }
            }
            return SAStruct(0, address(0), 0, false, 0);
        }
    }

    /**
     * @notice Get SuperAdmin by index
     * @dev Get SuperAdmin by index
     * @param _index                                            Index of the SuperAdmin
     * @return SAStruct                                         SuperAdmin data
     */
    function getSuperAdminByID(uint256 _index) public view returns (SAStruct memory){
        return _SA[_index];
    }

    /**
     * @notice Get SuperAdmin List
     * @dev Get SuperAdmin List
     */
    function adminList() external view returns (SAStruct[] memory) {
        unchecked {
            SAStruct[] memory stakes = new SAStruct[](_SACount);
            for (uint256 i = 0; i < _SACount; i++) {
                SAStruct storage s = _SA[i];
                stakes[i] = s;
            }
            return stakes;
        }
    }



    /**
     * @notice Send SuperAdmin commission
     * @dev Send SuperAdmin commission
     * @param _type                                                     SuperAdmin type
     * @param _buyer                                                     Buyer wallet address
     * @param _isNative                                                 Native or ERC20
     * @param _token                                                    Token address
     * @param _amount                                                   Commission Amount to distribute
     * @param _totalAmount                                              Total Amount to distribute
     */
    function sendComissionAdmin(
        uint _type,
        address _buyer,
        bool _isNative,
        address _token,
        uint256 _amount,
        uint256 _totalAmount
    ) internal {

        /// @dev For each SuperAdmin in the list
        for (uint256 i = 0; i < _SACount; i++) {
            SAStruct storage s = _SA[i];

            /// @dev If SuperAdmin is active and the same type of SuperAdmin especified
            if (s.active && s._type == _type) {

                /// @dev Calculate SuperAdmin commission remaing
                uint comission = calculatePercentage(_amount, s.commission);

                /// @dev Calculate SuperAdmin commission remaing in USD
                // uint256 commissionUSD = calculatePercentage(_amountUSD, s.commission);

                /// @dev Send Commission with Native token
                if (_isNative) {
                    (bool success, ) = payable(s.addr).call{value: comission}("");
                    require(
                        success,
                        "Send Comission Admin: Not enought tokens to pay for the Native transfer"
                    );
                }

                /// @dev Send Commission with ERC20 token
                else {
                    transferToken(_token, s.addr, comission);
                }

                /// @dev Store SuperAdmin commission to remaing logs
                ITransactions(transactionContractService)._storeSALog(
                    _token,
                    s.addr,
                    _buyer,
                    comission,
                    _totalAmount
                );
            }
        }
    }

    /**
     * @notice Register SuperAdmin and Admin
     * @dev Register SuperAdmin and Admin
     * @param _type                                                 Type of the SuperAdmin (1: SuperAdmin, 2: Admin) 
     * @param _addr                                                 Wallet addresss    
     * @param _percentage                                           Porcentaje of distribution to assign
     * @param _active                                               Document status
     */
    function _registerSuperAdmin(
        uint8 _type,
        address _addr,
        uint256 _percentage,
        bool _active
    ) public {
        /// @dev Get SuperAdmin data
        SAStruct memory superAdmin = getSuperAdmin(_addr);

        /// @dev Check SuperAdmin is not registered
        require(
            superAdmin.addr == address(0),
            "SuperAdmin is already registered"
        );

        /// @dev Check SuperAdmin percentaje available to distribute
        if(_type == 1){
            require(
                validPercentage(_percentage, percentageSuperAdmin),
                "registerSuperAdmin: Invalid percentage"
            );

        /// @dev Check Admin percentaje available to distribute
        }else if(_type == 2){
            require(
                validPercentage(_percentage, percentageAdmin),
                "registerAdmin: Invalid percentage"
            );
        
        /// @dev Invalid request
        }else{
            require(false, "registerSuperAdmin: Invalid type");
        }

        /// @dev Store on Mapping
        _SA[_SACount] = SAStruct(_type, _addr, _percentage, _active, _SACount);

        /// @dev Increase count of SuperAdmin
        _SACount++;

        /**
         * @dev Start SuperAdmin Counters
         * - Transaction count
         * - Commission balance
         * - Volumen balance
         */
        ITransactions(transactionContractService).startSACounters(_addr);

        /// @dev Update SuperAdmin porcentaje distribution
        if(_type == 1){
            percentageSuperAdmin = percentageSuperAdmin.add(_percentage);

        /// @dev Update Admin porcentaje distribution
        }else if(_type == 2){
            percentageAdmin = percentageAdmin.add(_percentage);
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../helpers/Utils.sol";
import "../Interfaces/ITransactions.sol";

contract Ambassador is Utils {

    /// @dev SafeMath library
    using SafeMath for uint256;

    /**
     * @notice Ambassador Data Struct
     * @dev Ambassador Data Struct
     * @param _type                                     Type of the ambassador  (0: Vip, 1: Ambassador)
     * @param commission                                Percent of commission
     * @param createdBy                                 Wallet address of the creator
     * @param addr                                      Wallet address of the ambassador
     * @param username                                  User name of the ambassador
     * @param active                                    Document status
     * @param index                                     Index
     */
    struct AmbassadorStruct {
        uint256 _type;
        uint256 commission;
        address createdBy;
        address addr;
        string username;
        bool active;
        uint256 index;
    }

    /// @dev Mapping of ambassadors
    mapping(uint256 => AmbassadorStruct) private _Ambassador;

    /// @dev Count of ambassadors
    uint256 public AmbassadorCount;

    /**
     * @notice Constructor Method
     * @dev Constructor Method
     */
    constructor() {
        AmbassadorCount = 0;
    }

    /**
     * @notice Register an Ambassador
     * @dev Register an Ambassador
     * @param _type                                     Type of the ambassador  (0: Vip, 1: Ambassador)
     * @param _commission                               Percent of commission
     * @param _addrAmbassador                           Wallet address of the ambassador
     * @param _username                                 User name of the ambassador
     * @param _active                                   Document status
     */
    function registerAmbassador(
        uint256 _type,
        uint256 _commission,
        address _addrAmbassador,
        string memory _username,
        bool _active
    ) public {
        _registerAmbassador(
            _type,
            _commission,
            _msgSender(),
            _addrAmbassador,
            _username,
            _active
        );
    }

    /**
     * @notice Edit Ambassador data Struct
     * @dev Edit Ambassador data Struct
     * @param _type                                     Input type of operation
     * @param _index                                    Index of the Ambassador
     * @param _addr                                     Input wallet address
     * @param _amount                                   Input amount
     * @param _string                                   Input string
     * @param _active                                   Input document status
     */
    function editAmbassador(
        uint8 _type,
        uint256 _index,
        address _addr,
        uint _amount,
        string memory _string,
        bool _active
    ) external {

        /// @dev check is a valid request
        require(
            _type <= 4,
            "editAmbassador: Invalid Request Type"
        );

        /// @dev get Amabassador data
        AmbassadorStruct memory ambassador = getAmbassadorByID(_index);

        /// @dev check if the ambassador is already registered
        require(
            ambassador.addr != address(0),
            "editAmbassador: User doesn't exist"
        );

        /// @dev Update Ambassador data
        _editAmbassador(
            ambassador.index, 
            _type, 
            _addr, 
            _amount, 
            _string, 
            _active
        );
    }

    /**
     * @notice Get Ambassador by username or wallet address
     * @dev Get Ambassador by username or wallet address
     * @param _username                                 User name of the ambassador      
     * @param _addr                                     Wallet address of the ambassador
     * @return AmbassadorStruct                         Ambassador data
     */
    function getAmbassador(
        string memory _username, 
        address _addr
    ) public view returns (AmbassadorStruct memory){
        unchecked {
            for (uint256 i = 0; i < AmbassadorCount; i++) {
                if (
                    keccak256(abi.encodePacked(_Ambassador[i].username)) ==
                    keccak256(abi.encodePacked(_username)) ||
                    _Ambassador[i].addr == _addr
                ) {
                    return _Ambassador[i];
                }
            }
            return AmbassadorStruct(0, 0, address(0), address(0), "", false, 0);
        }
    }

    /**
     * @notice Get Ambassador by index
     * @dev Get Ambassador by index
     * @param _index                                    Index of the ambassador
     * @return AmbassadorStruct                         Ambassador data
     */
    function getAmbassadorByID(uint256 _index) public view returns (AmbassadorStruct memory){
        return _Ambassador[_index];
    }

    /**
     * @notice Get Ambassador List
     * @dev Get Ambassador List
     */
    function AmbassadorList() external view returns (AmbassadorStruct[] memory){
        unchecked {
            AmbassadorStruct[] memory p = new AmbassadorStruct[](
                AmbassadorCount
            );

            for (uint256 i = 0; i < AmbassadorCount; i++) {
                AmbassadorStruct storage s = _Ambassador[i];
                p[i] = s;
            }

            return p;
        }
    }

    /**
     * @notice register an Ambassador
     * @dev register an Ambassador
     * @param _type                                     Type of the ambassador  (0: Vip, 1: Ambassador)
     * @param _commission                               Percent of commission
     * @param _createdBy                                Wallet address of the ambassador
     * @param _addrAmbassador                           Wallet address of the ambassador
     * @param _username                                 User name of the ambassador
     * @param _active                                   Document status
     */
    function _registerAmbassador(
        uint256 _type,
        uint256 _commission,
        address _createdBy,
        address _addrAmbassador,
        string memory _username,
        bool _active
    ) public {

        /// @dev check if the ambassador wallet address is valid
        require(
            _addrAmbassador != address(0),
            "Add Advisor: Wallet cannot be empty"
        );

        /// @dev get Amabassador data
        AmbassadorStruct memory ambassador = getAmbassador(
            _username,
            _addrAmbassador
        );

        /// @dev check if the ambassador is already registered
        require(
            ambassador.addr == address(0),
            "registerAmbassador: User already exist"
        );

        /// @dev  Store ambassador
        _Ambassador[AmbassadorCount] = AmbassadorStruct(
            _type,
            _commission,
            _createdBy,
            _addrAmbassador,
            _username,
            _active,
            AmbassadorCount
        );

        /// @dev count the number of pairs
        AmbassadorCount++;

        /// @dev count the number of advisors

        /**
         * @dev Start Ambassador Counters
         * - Transaction count
         * - Commission balance
         * - Volumen balance
         */
        ITransactions(transactionContractService).startAmbassadorCounters(_addrAmbassador);
    }

    /**
     * @notice Edit Ambassador data Struct
     * @dev Edit Ambassador data Struct
     * @param _index                                    Index of the ambassador
     * @param _type                                     Input type of operation
     * @param _addr                                     Input wallet address
     * @param _amount                                   Input amount
     * @param _string                                   Input string
     * @param _active                                   Input document status
     */
    function _editAmbassador(
        uint256 _index,
        uint8 _type,
        address _addr,
        uint256 _amount,
        string memory _string,
        bool _active
    ) public {

        /// @dev get Amabassador data
        AmbassadorStruct memory ambassador = _Ambassador[_index];

        /// @dev check if the ambassador is already registered
        require(
            ambassador.addr != address(0),
            "_editAmbassador: User doesn't exist"
        );

        /// @dev Update Ambassador wallet address
        if(_type == 1){
            _Ambassador[_index].addr = _addr;

        /// @dev Update Ambassador username
        }else if(_type == 2){
            _Ambassador[_index].username = _string;

        /// @dev Update Ambassador document status
        }else if(_type == 3){
            _Ambassador[_index].active = _active;

        /// @dev Update Ambassador commission amount
        }else if(_type == 4){
            _Ambassador[_index].commission = _amount;

        /// @dev Update Ambassador created by
        }else if(_type == 5){
            _Ambassador[_index].createdBy = _addr;

        /// @dev Update Ambassador type
        }else if(_type == 6){
            _Ambassador[_index]._type = _amount;
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Ambassador.sol";
import "../Interfaces/ITransactions.sol";

contract VIP is Ambassador {

    // @dev SafeMath library
    using SafeMath for uint256;

    /**
     * @dev Vip data struct
     * @param addressAmbassador                                     Wallet address of the ambassador
     * @param addr                                                  Wallet address of the VIP
     * @param username                                              User name of the VIP
     * @param active                                                Document status
     * @param index                                                 Index
     */
    struct VipStruct {
        address addressAmbassador;
        address addr;
        string username;
        bool active;
        uint256 index;
    }

    /// @dev Mapping of VIP's
    mapping(uint256 => VipStruct) private _VipPartners;

    /// @dev Nro of VIP's registered
    uint256 public vipCount;

    /**
     * @notice Constructor Method
     * @dev Constructor Method
     */
    constructor() {
        vipCount = 0;
    }

    /**
     * @dev Register a VIP
     * @param _addr                                                 Wallet address of the VIP
     * @param _username                                             User name of the VIP
     * @param _active                                               Document status
     */
    function registerVIP(
        address _addr,
        string memory _username,
        bool _active
    ) public {

        /// @dev get Amabassador data
        AmbassadorStruct memory ambassador = getAmbassador('', _msgSender());

        /// @dev check if the ambassador wallet address is valid
        require(
            ambassador.addr != address(0) && ambassador.active,
            "registerVIP: Invalid Ambassador"
        );

        return _registerVIP(_msgSender(), _addr, _username, _active);
    }

    /**
     * @notice Update
     * @dev Update
     * @param _index                                            Index of the VIP
     * @param _type                                             Operation type
     * @param _username                                         Input username
     * @param _addr                                             Input string
     * @param _active                                           Input document status
     */
    function editVIP(
        uint256 _index,
        uint8 _type,
        string memory _username,
        address _addr,
        bool _active
    ) public {

        /// @dev check is a valid request
        require(
            _type <= 3,
            "editVIP: Invalid Request Type"
        );

        /// @dev get Amabassador data
        AmbassadorStruct memory ambassador = getAmbassador('', _msgSender());

        /// @dev check if the ambassador wallet address is valid
        require(
            ambassador.addr != address(0) && ambassador.active,
            "registerVIP: Invalid Ambassador"
        );

        /// @dev Get Vip data
        VipStruct memory vip = getVipByID(_index);

        /// @dev check if the VIP is already registered
        require(
            vip.addr != address(0),
            "_editVIP: User doesn't exist"
        );

        return _editVIP(
            vip.index,
            _type,
            _addr,
            _username,
            _active
        );
    }

    /**
     * @dev Get VIP by username or wallet address
     * @param _username                                         Username of the VIP
     * @param _addr                                             Wallet address of the VIP
     */
    function getVip(
        string memory _username, 
        address _addr
    ) public view returns (VipStruct memory) {
        unchecked {
            for (uint256 i = 0; i < vipCount; i++) {
                if (
                    keccak256(abi.encodePacked(_VipPartners[i].username)) ==
                    keccak256(abi.encodePacked(_username)) ||
                    _VipPartners[i].addr == _addr
                ) {
                    return _VipPartners[i];
                }
            }
            return VipStruct(address(0), address(0), "", false, 0);
        }
    }

    /**
     * @notice Get VIP by index
     * @dev Get VIP by index
     * @param _index                                            Index of the VIP
     * @return VipStruct                                        VIP data
     */
    function getVipByID(uint256 _index) public view returns (VipStruct memory) {
        return _VipPartners[_index];
    }

    /**
     * @notice Get VIP List
     * @dev Get VIP List
     */
    function vipList() 
        external view returns (VipStruct[] memory) 
    {
        unchecked {
            VipStruct[] memory p = new VipStruct[](vipCount);

            for (uint256 i = 0; i < vipCount; i++) {
                VipStruct storage s = _VipPartners[i];
                p[i] = s;
            }

            return p;
        }
    }

    /**
     * @dev Register a VIP
     * @param _addressAmbassador                                    Wallet address of the ambassador
     * @param _addr                                                 Wallet address of the VIP
     * @param _username                                             User name of the VIP
     * @param _active                                               Document status
     */
    function _registerVIP(
        address _addressAmbassador,
        address _addr,
        string memory _username,
        bool _active
    ) public {

        /// @dev get Amabassador data
        AmbassadorStruct memory ambassador = getAmbassador('', _addressAmbassador);

        /// @dev check if the ambassador wallet address is valid
        require(
            ambassador.addr != address(0),
            "_registerVIP: Invalid Ambassador"
        );

        /// @dev check if VIP wallet address is valid
        require(_addr != address(0), "_registerVIP: Wallet cannot be empty or 0x0");

        /// @dev Get Vip data
        VipStruct memory vip = getVip(_username, _addr);

        /// @dev check if the VIP is already registered
        require(
            vip.addr == address(0),
            "_registerVIP: User already exist"
        );

        /// @dev  Store VIP
        _VipPartners[vipCount] = VipStruct(
            _addressAmbassador,
            _addr,
            _username,
            _active,
            vipCount
        );

        /// @dev count the number of pairs
        vipCount++;

        /**
         * @dev Start VIP Counters
         * - Transaction count
         * - Commission balance
         * - Volumen balance
         */
        ITransactions(transactionContractService).startVIPCounters(_addr);
    }

    /**
     * @dev Edit a VIP
     * @param _index                                            Index of the VIP                                        
     * @param _type                                             Input type of operation
     * @param _addr                                             Input wallet address                                     
     * @param _string                                           Input string                                      
     * @param _active                                           Input document status                                    
     */
    function _editVIP(
        uint256 _index,
        uint8 _type,
        address _addr,
        string memory _string,
        bool _active
    ) public {

        /// @dev Get Vip data
        VipStruct memory vip = _VipPartners[_index];

        /// @dev check if the VIP is already registered
        require(
            vip.addr != address(0),
            "_editVIP: User doesn't exist"
        );

        /// @dev Update VIP wallet address
        if(_type == 1){
            _VipPartners[_index].addr = _addr;

        /// @dev Update VIP username
        }else if(_type == 2){
            _VipPartners[_index].username = _string;

        /// @dev Update VIP document status
        }else if(_type == 3){
            _VipPartners[_index].active = _active;

        /// @dev Update VIP Ambassador wallet
        }else if(_type == 4){

            /// @dev get Amabassador data
            AmbassadorStruct memory ambassador = getAmbassador('', _addr);

            /// @dev check if the ambassador wallet address is valid
            require(
                ambassador.addr != address(0) ,
                "_editVIP: Invalid Ambassador"
            );
            
            _VipPartners[_index].addressAmbassador = _addr;
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// 0x4108D427E1b78F8ff9F6752601BDf20e72e66198
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../security/SoftAdministered.sol";

contract WhiteListTokens is SoftAdministered {

    /// @dev SafeMath library
    using SafeMath for uint256;

    /**
     * @notice ERC20 WhiteList struct
     * @dev ERC20 WhiteList struct
     * @param tokenAddress                              Token Contract Address
     * @param oracleAddress                             Oracle Address
     * @param active                                    Document status
     * @param isNative                                  Native token
     * @param index                                     Index
     */
    struct ERC20List {
        address tokenAddress;
        address oracleAddress;
        bool active;
        bool isNative;
        uint256 index;
    }

    /**
     * @notice ERC20 WhiteList struct
     * @dev ERC20 WhiteList struct
     * @param tokenAddress                              Token Contract Address    
     * @param tokenName                                 Token Name
     * @param tokenSymbol                               Token Symbol
     * @param tokenDecimals                             Token Decimals
     * @param tokenDecimalsLeft                         Token Decimals Left
     * @param oracleAddress                             Oracle Address
     * @param oracleDescription                         Oracle Description
     * @param oracleDecimals                            Oracle Decimals
     * @param oracleDecimalsLeft                        Oracle Decimals Left
     * @param active                                    Document status
     * @param isNative                                  Native token
     * @param index                                     Index
     */
    struct ERC20Details {
        address tokenAddress;
        string tokenName;
        string tokenSymbol;
        uint256 tokenDecimals;
        uint256 tokenDecimalsLeft;
        address oracleAddress;
        string oracleDescription;
        uint256 oracleDecimals;
        uint256 oracleDecimalsLeft;
        bool active;
        bool isNative;
        uint256 index;
    }

    /**
     * @notice ERC20 WhiteList token by address struct
     * @dev ERC20 WhiteList token by address struct
     * @param tokenAddress                              Token Contract Address
     * @param index                                     Index
     */
    struct ERC20AddressList {
        address tokenAddress;
        uint256 index;
    }

    /// @dev List of addresses that have a number of reserved tokens for whitelist
    mapping(uint256 => ERC20List) public whitelistTokensPay;

    /// @dev Mapping of token address position
    mapping(address => ERC20AddressList) public whitelistTokenAddress;

    /// @dev WhiteList token Counter
    uint256 public whitelistTokenCount;

    constructor() {
        whitelistTokenCount = 0;
    }

    /**
     * @notice Store ERC20 Token
     * @dev Store ERC20 Token
     * @param _tokenAddress                              Token Contract Address
     * @param _oracleAddress                             Oracle Address
     * @param _active                                    Document status
     * @param _isNative                                  Native token
     */
    function storeWhitListToken(
        address _tokenAddress,
        address _oracleAddress,
        bool _active,
        bool _isNative
    ) public onlyOwner {
        _storeWhitListToken(
            _tokenAddress,
            _oracleAddress,
            _active,
            _isNative
        );
    }

    /**
     * @notice Update ERC20 Token
     * @dev Update ERC20 Token
     * @param _id                                       Index
     * @param _type                                     Operation type
     * @param _addr                                     Input address
     * @param _bool                                     Input document status
     */
    function updateWhiteListToken(
        uint256 _id,
        uint256 _type,
        address _addr,
        bool _bool
    ) public onlyOwner {
        _updateWhiteListToken(
            _id,
            _type,
            _addr,
            _bool
        );
    }

    /**
     * @notice Get WhiteList Token List
     * @dev Get WhiteList Token List
     */
    function whitelistTokensPayList()
        external view returns (ERC20List[] memory)
    {
        unchecked {
            ERC20List[] memory p = new ERC20List[](whitelistTokenCount);
            for (uint256 i = 0; i < whitelistTokenCount; i++) {
                ERC20List storage s = whitelistTokensPay[i];
                p[i] = s;
            }
            return p;
        }
    }

    /**
     * @notice Get WhiteList Detail Token List
     * @dev Get WhiteList Detail Token List
     */
    function whiteListTokenDetails()
        external view returns (ERC20Details[] memory)
    {
        unchecked {

            /// @dev Create a list of ERC20 Tokens
            ERC20Details[] memory p = new ERC20Details[](whitelistTokenCount);
            
            /// @dev Read for each ERC20 Token stored
            for (uint256 i = 0; i < whitelistTokenCount; i++) {

                /// @dev Get Index
                uint256 index = uint256(whitelistTokensPay[i].index);

                /// @dev Push ERC20 Details Tokens list
                p[i] = _getWhiteListTokenInfoByID(index);
            }
            return p;
        }
    }

    /**
     * @notice Verify if the token is in the whitelist
     * @dev Verify if the token is in the whitelist
     * @param _tokenAddress                                 Address of the token contract
     * @return bool                                         True if the token is in the whitelist
     */
    function isWhiteListToken(
        address _tokenAddress
    ) public view returns (bool) {
        if (whitelistTokenAddress[_tokenAddress].tokenAddress == address(0x0)) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * @notice Get ERC20 Token data
     * @dev Get ERC20 Token data
     * @param _tokenAddress                                 Address of the token contract
     * @return ERC20Details                                 ERC20 Token data
     */
    function getWhiteListTokenInfo(
        address _tokenAddress
    ) public view returns (ERC20Details memory){

        /// @dev Get WhiteList Token data
        ERC20AddressList storage row = whitelistTokenAddress[_tokenAddress];

        /// @dev Check if the token is stored
        require(
            row.tokenAddress != address(0x0),
            "getWhiteListTokenInfo: Token not found"
        );

        /// @dev Return ERC20 Details Token data
        return _getWhiteListTokenInfoByID(row.index);
    }

    function getWhiteListTokenInfoMetadata(
        address _tokenAddress
    ) public view returns (
        address,
        string memory,
        string memory,
        uint256,
        uint256,
        address,
        string memory,
        uint256,
        uint256,
        bool,
        bool,
        uint256
    ){

        /// @dev Get WhiteList Token data
        ERC20AddressList storage row = whitelistTokenAddress[_tokenAddress];

        /// @dev Check if the token is stored
        require(
            row.tokenAddress != address(0x0),
            "getWhiteListTokenInfo: Token not found"
        );

        /// @dev Return ERC20 Details Token data
        ERC20Details memory document = _getWhiteListTokenInfoByID(row.index);

        return (
            document.tokenAddress,
            document.tokenName,
            document.tokenSymbol,
            document.tokenDecimals,
            document.tokenDecimalsLeft,
            document.oracleAddress,
            document.oracleDescription,
            document.oracleDecimals,
            document.oracleDecimalsLeft,
            document.active,
            document.isNative,
            document.index
        );
    }

    /**
     * @notice Store ERC20 Token
     * @dev Store ERC20 Token
     * @param _tokenAddress                              Token Contract Address
     * @param _oracleAddress                             Oracle Address
     * @param _active                                    Document status
     * @param _isNative                                  Native token
     */
    function _storeWhitListToken(
        address _tokenAddress,
        address _oracleAddress,
        bool _active,
        bool _isNative
    ) internal {

        /// @dev Check ERC20 doesn't exist
        require(
            isWhiteListToken(_tokenAddress) == false,
            "Add Token Collection already exist"
        );

        /// @dev Document position
        uint256 pointer = whitelistTokenCount;

        /// @dev add token to whitelist
        whitelistTokensPay[pointer] = ERC20List(
            _tokenAddress,
            _oracleAddress,
            _active,
            _isNative,
            pointer
        );

        /// @dev Add token to address list
        whitelistTokenAddress[_tokenAddress] = ERC20AddressList(
            _tokenAddress,
            pointer
        );

        /// @dev Increment whitelistTokenCount
        whitelistTokenCount++;
    }

    /**
     * @notice Update ERC20 Token
     * @dev Update ERC20 Token
     * @param _id                                       Index
     * @param _type                                     Operation type
     * @param _addr                                     Input address
     * @param _bool                                     Input document status
     */
    function _updateWhiteListToken(
        uint256 _id,
        uint256 _type,
        address _addr,
        bool _bool
    ) internal {

        /// @dev Get ERC20 Token data
        ERC20List memory erc20Token = whitelistTokensPay[_id];

        /// @dev Check ERC20 Token exists
        require(
            erc20Token.tokenAddress != address(0),
            "_updateWhiteListToken: Invalid Token "
        );

        /// @dev Update Oracle address
        if (_type == 1) {
            whitelistTokensPay[_id].oracleAddress = _addr;

        /// @dev Update document status
        } else if (_type == 2) {
            whitelistTokensPay[_id].active = _bool;

        /// @dev Update Native token
        } else if (_type == 3) {
            whitelistTokensPay[_id].isNative = _bool;
        }
    }

    /**
     * @notice Get WhiteListToken Details
     * @dev Get WhiteListToken Details
     * @param _id                                           Token Index
     * @return ERC20Details                                 ERC20 Details data
     */
    function _getWhiteListTokenInfoByID(
        uint256 _id
    ) internal view returns (ERC20Details memory){

        /// @dev Get ERC20 Token data
        ERC20List memory erc20Token = whitelistTokensPay[_id];

        /// @dev Create ERC20Details data
        ERC20Details memory ERC20TokenDetails;

        uint256 totalDecimals = 18;

        /// @dev Set ERC20 Token data
        ERC20TokenDetails.tokenAddress = erc20Token.tokenAddress;
        ERC20TokenDetails.tokenName = (!erc20Token.isNative)
            ? ERC20(erc20Token.tokenAddress).name()
            : '';
        ERC20TokenDetails.tokenSymbol = (!erc20Token.isNative)
            ? ERC20(erc20Token.tokenAddress).symbol()
            : '';
        ERC20TokenDetails.tokenDecimals = (!erc20Token.isNative)
            ? ERC20(erc20Token.tokenAddress).decimals()
            : totalDecimals;
        ERC20TokenDetails.tokenDecimalsLeft = (!erc20Token.isNative)
            ? totalDecimals.sub(ERC20TokenDetails.tokenDecimals)
            : totalDecimals;

        /// @dev Create Oracle Interface
        AggregatorV3Interface oracleInterface = AggregatorV3Interface(erc20Token.oracleAddress);

        /// @dev Set Oracle data
        ERC20TokenDetails.oracleAddress = erc20Token.oracleAddress;
        ERC20TokenDetails.oracleDescription = oracleInterface.description();

        uint256 oracleDecimals = uint256(oracleInterface.decimals());
        ERC20TokenDetails.oracleDecimals = oracleDecimals;
        ERC20TokenDetails.oracleDecimalsLeft = totalDecimals.sub(oracleDecimals);

        ERC20TokenDetails.active = erc20Token.active;
        ERC20TokenDetails.isNative = erc20Token.isNative;
        ERC20TokenDetails.index = erc20Token.index;

        return ERC20TokenDetails;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../helpers/Utils.sol";
import "../Interfaces/IPropertyToken.sol";
import "../Interfaces/IOracle.sol";

contract Bonus is Utils {

    /**
     * @notice LNDA Bonus data struct
     * @dev LNDA Bonus data struct
     * @param active                                            Document status         
     * @param amountLnda                                        Amount of LNDA bonus
     * @param addrNFT                                           Contract address of NFT
     */
    struct bonoStruct {
        bool active;
        uint priceUsd;
        uint256 amountLnda;
        address addrNFT;
    }

    /// @dev Mapping of LNDA Bonus
    mapping(uint256 => bonoStruct) public tokenNFTAndLndaAddress;

    /// @dev Contract address of LNDA Token
    address public addressLnda = address(0);

    /// @dev Counter of LNDA Bonus
    uint256 public _nftCount;

    /**
     * @notice Constructor Method
     * @dev Constructor Method
     */
    constructor() {
        _nftCount = 0;
    }

    /**
     * @notice Set token address for NFT and LNDA bonus
     * @dev Set token address for NFT and LNDA bonus
     * @param _amount                                               Input value to assign
     * @param _tokenAddress                                         Input token address to assing
     */
    function setTokenAddressNFTAndLnda(
        uint256 _amount, 
        address _tokenAddress,
        uint256 _priceUsd
    ) external onlyAdminRoot {

        /// @dev Store LNDA Bonues data
        tokenNFTAndLndaAddress[_nftCount] = bonoStruct(
            true,
            _priceUsd,
            _amount,
            _tokenAddress
        );

        /// @dev Increment count of NFT Bonus List
        _nftCount++;
    }

    /**
     * @notice Update LNDA Bonus data struct
     * @dev Update LNDA Bonus data struct
     * @param _type                                                 Operation type
     * @param _id                                                   Index
     * @param _amount                                               Input value to assign
     * @param _tokenAddress                                         Input token address to assing
     * @param _active                                               Input document status
     */
    function editTokenAddressNFTAndLnda(
        uint256 _type,
        uint256 _id,
        uint256 _amount,
        address _tokenAddress,
        bool _active
    ) external onlyAdminRoot {
        /// @dev update price Package 
        if(_type == 0){
            tokenNFTAndLndaAddress[_id].priceUsd = _amount;
            
        /// @dev Update LNDA amount
        } else if (_type == 1) {
            tokenNFTAndLndaAddress[_id].amountLnda = _amount;

        /// @dev Update NFT contract address
        } else if (_type == 2) {
            tokenNFTAndLndaAddress[_id].addrNFT = _tokenAddress;
            
        /// @dev Update document status
        } else if (_type == 3) {
            tokenNFTAndLndaAddress[_id].active = _active;

        /// @dev Update LNDA contract address
        } else if (_type == 4) {
            addressLnda = _tokenAddress;
        }
    }

    /**
     * @notice Send NFT Token
     * @dev Send NFT Token
     * @param _type                                                         NFT Type
     * @param _addr                                                         Wallet address to send tokens
     */
    function sendNft(uint256 _type, address _addr) internal {

        /// @dev Store LNDA address
        address LNDAContract = addressLnda;

        /// @dev Get Bono NFT data
        bonoStruct memory bono = tokenNFTAndLndaAddress[_type];

        /// @dev Check Bonus NFT is active
        require(bono.active, "Send NFT And tokens: Token is not active");

        /// @dev Send NFT Token Bonus
        IPropertyToken(bono.addrNFT).mintReserved(_addr, 1);

        /// @dev Send LNDA Token Bonus
        transferToken(LNDAContract, _addr, bono.amountLnda);
    }

    function validateBuyBonusPackage(
        uint256 _type,
        address _token,
        uint256 _amount
    ) internal view returns(bool){

        require(
            _amount > 0,
            "Send NFT And tokens: Amount must be greater than 0"
        );

        bonoStruct memory bono = tokenNFTAndLndaAddress[_type];

        /// @dev Check Bonus NFT is active
        require(bono.active, "Send NFT And tokens: Token is not active");

        uint256 _amountTokenParsedUSD = IOracle(oracleContractService).parseAmountToUSD(_amount, _token);

        /// @dev Check if amount is greater than price
        require(_amountTokenParsedUSD >= bono.priceUsd, "Send NFT And tokens: Amount is less than price");

        return true;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../factory/WhiteListTokens.sol";
import "../security/SoftAdministered.sol";

contract Oracle is SoftAdministered {

    /// @dev SafeMath library
    using SafeMath for uint256;

    /// @dev WhiteList Contract Service
    address public whiteListContractService;

    /**
     * @notice Constructor Method
     * @dev Constructor Method
     */
    constructor(){
        whiteListContractService = address(0x0);
    }

    /**
     * @dev Update WhiteList Contract Service address
     * @param _addr                                                 Contract address
     */
    function setWhiteListContractService(address _addr) public onlyOwner{
        whiteListContractService = _addr;
    }

    /**
     * @dev Get USD Price of token
     * @param _token                                                Token address
     * @return uint256                                              USD Price of token
     */
    function getUSDPrice(address _token) public view returns (uint256) {

        WhiteListTokens whiteListService = WhiteListTokens(whiteListContractService);

        require(
            whiteListService.isWhiteListToken(_token),
            "Token is not whitelisted"
        );
        
        address oracleAddress = whiteListService.getWhiteListTokenInfo(_token).oracleAddress;
        uint256 oracleDecimalsLeft = whiteListService.getWhiteListTokenInfo(_token).oracleDecimalsLeft;

        AggregatorV3Interface oracle = AggregatorV3Interface(oracleAddress);
        (, int256 price, , , ) = oracle.latestRoundData();

        return uint256(price) * 10**oracleDecimalsLeft;
    }

    /**
     * @dev Get last price of token
     * @param _oracle                                               Oracle address
     * @param _decimals                                             Decimals of token
     * @return uint256                                              Price of token
     */
    function getLatestPrice(
        address _oracle, 
        uint256 _decimals
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_oracle);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * 10**_decimals;
    }

    /**
     * @dev Parse amount token from USD
     * @param _amount                                               Amount in USD (WEI)
     * @param _token                                                Token address   
     * @return uint256                                              Amount in tokens
     */
    function parseAmountFromUSD(
        uint256 _amount,
        address _token
    ) public view returns (uint256) {

        /// @dev Get Oracle price on 18 decimals
        uint256 _price = getUSDPrice(_token);

        /// @dev Calculate amount to send
        uint256 unity = 1 ether;
        uint256 amountToSend = _amount.mul(unity).div(_price);

        WhiteListTokens whiteListService = WhiteListTokens(whiteListContractService);

        uint256 tokenDecimals = whiteListService.getWhiteListTokenInfo(_token).tokenDecimals;

        uint256 _parseToTokenDecimals = transformAmountToTokenDecimals(amountToSend, tokenDecimals);

        return _parseToTokenDecimals;
    }

    /**
     * @dev Parse amount token to USD
     * @param _amount                                               Amount of token
     * @param _token                                                Token address   
     * @return uint256                                              Amount in USD
     */
    function parseAmountToUSD(
        uint256 _amount,
        address _token
    ) public view returns (uint256) {

        /// @dev Get Oracle price on 18 decimals
        uint256 _price = getUSDPrice(_token);

        WhiteListTokens whiteListService = WhiteListTokens(whiteListContractService);

        uint256 tokenDecimals = whiteListService.getWhiteListTokenInfo(_token).tokenDecimals;

        /// @dev Parse amount to WEI
        uint256 _parseTo18 = transformAmountTo18Decimal(_amount, tokenDecimals);

        uint256 unity = 1 ether;
        uint256 amountToSend = _parseTo18.mul(_price).div(unity);

        return amountToSend;
    }

    /**
     * @notice Parse amount to 18 decimals
     * @dev Parse amount to 18 decimals
     * @param _amount                           Amount to convert   
     * @param _decimal                          Decimal of token
     */
    function transformAmountTo18Decimal(
        uint256 _amount, 
        uint256 _decimal
    ) internal pure returns (uint256) {
        if (_decimal == 18) {
            return _amount;
        } else if (_decimal == 8) {
            return _amount.mul(10**10);
        } else if (_decimal == 6) {
            return _amount.mul(10**12);
        } else if (_decimal == 3) {
            return _amount.mul(10**15);
        } else if (_decimal == 0) {
            return _amount.mul(10**18);
        }
        return 0;
    }

    /**
     * @notice Parse amount to token decimals
     * @dev Parse amount to token decimals
     * @param _amount                           Amount to convert   
     * @param _decimals                         Decimals of token
     */
    function transformAmountToTokenDecimals(
        uint256 _amount, 
        uint256 _decimals
    )
        internal
        pure
        returns (uint256)
    {
        if (_decimals == 18) {
            return _amount;
        } else if (_decimals == 8) {
            return _amount.div(10**10);
        } else if (_decimals == 6) {
            return _amount.div(10**12);
        } else if (_decimals == 3) {
            return _amount.div(10**15);
        }

        return 0;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../security/Administered.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../helpers/Utils.sol";

contract Withdraw is Utils {

    /**
     * @notice Allow the owner of the contract to withdraw BNB Owner
     * @dev Withdraw Native Token
     * @param _amount                           Amount to withdraw
     * @param _token                            Token address to withdraw
     * @param _type                             Operation type
     */
    function withdrawToken(
        uint256 _amount,
        address _token,
        uint _type
    ) external payable onlyAdminRoot {

        /// @dev Withdraw Native Token
        if (_type == 1) {
            (bool success, ) = payable(_msgSender()).call{value: _amount}("");
            require(success, "Send Comission Admin: transaction failed");

        /// @dev Withdraw ERC20 Token
        } else if (_type == 2) {
            require(
                IERC20(_token).transfer(_msgSender(), _amount),
                "Withdraw Token: Failed to transfer token to Onwer"
            );
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface for Contract Transactions
 */
interface ITransactions {

    /**
     * ===============================================
     * @dev         Store Transactions
     * ===============================================
     */

    /// @dev Store Ambassador transaction
    function _storeAmbassadorLog(
        address _token,
        address _host,
        address _buyer,
        uint256 commission,
        uint256 amount
    ) external;


    /// @dev Store VIP transaction
    function _storeVIPLog(
        address _token,
        address _host,
        address _buyer,
        uint256 commission,
        uint256 amount
    ) external;

    /// @dev Store SA transaction
    function _storeSALog(
        address _token,
        address _host,
        address _buyer,
        uint256 commission,
        uint256 amount
    ) external;

    /**
     * ===============================================
     * @dev      Manager Total Commission
     * ===============================================
     */

    /// @dev Update Ambassador Total Commission
    function updateAmbassadorCommission(
        uint8 _type,
        address _host,
        uint256 _commission
    ) external;

    /// @dev Update VIP Total Commission
    function updateVIPCommission(
        uint8 _type,
        address _host,
        uint256 _commission
    ) external;

    /// @dev Update SuperAdmin Total Commission
    function updateSACommission(
        uint8 _type,
        address _host,
        uint256 _commission
    ) external;

    /**
     * ===============================================
     * @dev      Manager Total Volumen
     * ===============================================
     */

    /// @dev Update Ambassador Total Volumen
    function updateAmbassadorVolumen(
        uint8 _type,
        address _host,
        uint256 _commission
    ) external;

    /// @dev Update VIP Total Volumen
    function updateVIPVolumen(
        uint8 _type,
        address _host,
        uint256 _commission
    ) external;

    /// @dev Update SuperAdmin Total Volumen
    function updateSAVolumen(
        uint8 _type,
        address _host,
        uint256 _commission
    ) external;

    /**
     * ===============================================
     * @dev      Start Counters
     * ===============================================
     */

    /// @dev Start Ambassador Counters
    function startAmbassadorCounters(
        address _host
    ) external;

    /// @dev Start VIP Counters
    function startVIPCounters(
        address _host
    ) external;

        /// @dev Start SuperAdmin Counters
    function startSACounters(
        address _host
    ) external;

    /**
     * ===============================================
     * @dev      Update Transaction Counters
     * ===============================================
     */

    /// @dev Update Ambassador Transaction Counter
    function updateAmbassadorLogCounter(
        address _host
    ) external;

    /// @dev Update VIP Transaction Counter
    function updateVIPLogCounter(
        address _host
    ) external;

    /// @dev Update SuperAdmin Transaction Counter
    function updateSALogCounter(
        address _host
    ) external;

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../security/Administered.sol";
import "../factory/WhiteListTokens.sol";

contract Utils is Administered {

    /// @dev WhiteList Contract Service
    address public whiteListContractService = address(0x0);

    /// @dev Oracle Contract Service
    address public oracleContractService = address(0x0);

    /// @dev Transaction Contract Service
    address public transactionContractService = address(0x0);

    function setWhiteListContractService(address _addr) external onlyAdminRoot {
        whiteListContractService = _addr;
    }

    function setOracleContractService(address _addr) external onlyAdminRoot {
        oracleContractService = _addr;
    }

    function setTransactionContractService(address _addr) external onlyAdminRoot {
        transactionContractService = _addr;
    }

    /**
     * @notice Calculate porcentaje of commission of a user in basic points
     * @dev Calculate porcentaje of commission of a user in basic points
     * @param _amount                                                 Amount to use in calculation
     * @param _percentage                                             Porcentaje of commission to get
     */
    function calculatePercentage(
        uint256 _amount, 
        uint256 _percentage
    ) public pure returns (uint256 fee) {
        return (_amount * _percentage) / 10000;
    }

    /**
     * @notice Transfer Native Token
     * @dev Transfer Native Token
     * @param _addr                                                         Address to transfer
     * @param _amount                                                       Amount of tokens to send
     */
    function transferNative(
        address _addr, 
        uint _amount
    ) internal {
        (bool sent, ) = address(_addr).call{value: (_amount)}("");
        require(sent, "Transfer Native: Error sending money");
    }

    /**
     * @notice Transfer Regular Token
     * @dev Transfer Regular Token
     * @param _token                                                        Contract Token address
     * @param _addr                                                         Wallet address to send tokens
     * @param _amount                                                       Amount of tokens to send
     */
    function transferToken(
        address _token,
        address _addr,
        uint _amount
    ) internal {
        require(
            IERC20(_token).transfer(_addr, _amount),
            "Transfer: Error sending money"
        );
    }

    function validateWhiteListToken(
        address _token,
        bool _isNative
    ) public view returns (bool) {

        /// @dev Create WhitelistContract Service Instance
        WhiteListTokens whiteListTokens = WhiteListTokens(whiteListContractService);

        /// @dev check if a whitelist token
        require(
            whiteListTokens.isWhiteListToken(_token),
            "Join With: Invalid token"
        );
        
        /// @dev check whitelist token is available
        require(
            whiteListTokens.getWhiteListTokenInfo(_token).active,
            "Join With: Token is not available"
        );

                /// @dev check whitelist token is available
        require(
            whiteListTokens.getWhiteListTokenInfo(_token).isNative == _isNative,
            "Join With: Invalid token type for this operation"
        );

        return true;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Administered
 * @notice Implements Admin and User roles.
 */
contract Administered is AccessControl {
    bytes32 public constant USER_ROLE_SUPER_ADMIN = keccak256("SUPER_ADMIN");
    bytes32 public constant USER_ROLE_ADMIN = keccak256("ADMIN");
    bytes32 public constant USER_ROLE_AMBASSADOR = keccak256("AMBASSADOR");
    bytes32 public constant USER_ROLE_USER = keccak256("USER");

    /// @dev Add `root` to the admin role as a member.
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setRoleAdmin(USER_ROLE_SUPER_ADMIN, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE_ADMIN, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE_AMBASSADOR, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(USER_ROLE_USER, DEFAULT_ADMIN_ROLE);

        /// @dev asigano el el creador d econtrato como un super admin
        grantRole(USER_ROLE_SUPER_ADMIN, _msgSender());
    }

    /// @dev Restricted to members of the admin role.
    modifier onlyAdminRoot() {
        require(isAdmin(_msgSender()), "Restricted to admins.");
        _;
    }

    /// @dev Restricted to members of the user role.
    modifier onlySuperAdmin() {
        require(isUser(_msgSender(), 0), "Restricted to Super Admin.");
        _;
    }

    modifier onlyAdmin() {
        require(isUser(_msgSender(), 1), "Restricted to Admin.");
        _;
    }

    modifier onlyAmbassador() {
        require(isUser(_msgSender(), 2), "Restricted to Ambassador.");
        _;
    }

    modifier onlyUser() {
        require(isUser(_msgSender(), 3), "Restricted to User.");
        _;
    }

    /// @dev Return `true` if the account belongs to the admin role.
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Add an account to the admin role. Restricted to admins.
    function addAdminRoot(address account) public virtual onlyAdminRoot {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function addUser(address account) public virtual onlyAdminRoot {
        return grantRole(USER_ROLE_USER, account);
    }

    /// @dev Add an account to the user role. Restricted to admins.
    function addSuperAdmin(address account) public virtual onlyAdminRoot {
        return grantRole(USER_ROLE_SUPER_ADMIN, account);
    }

    /// @dev Add Admin role
    function _addAdmin(address account) internal virtual {
        return grantRole(USER_ROLE_ADMIN, account);
    }

    /// @dev Add Admin role from super admin
    function addAdmin(address account) public virtual onlySuperAdmin {
        return _addAdmin(account);
    }

    /// @dev Add admin from admin
    function addAdminFromAdmin(address account) public virtual onlyAdmin {
        return _addAdmin(account);
    }

    function addAmbassador(address account) public virtual onlyAdmin {
        return grantRole(USER_ROLE_AMBASSADOR, account);
    }

    /// @dev Return `true` if the account belongs to the user role.
    function isUser(address account, uint256 typeAccount)
        public
        view
        virtual
        returns (bool)
    {
        if (typeAccount == 0) {
            return hasRole(USER_ROLE_SUPER_ADMIN, account);
        } else if (typeAccount == 1) {
            return hasRole(USER_ROLE_ADMIN, account);
        } else if (typeAccount == 2) {
            return hasRole(USER_ROLE_AMBASSADOR, account);
        } else if (typeAccount == 3) {
            return hasRole(USER_ROLE_USER, account);
        } else {
            return false;
        }
    }

    /// @dev Remove an account from the user role. Restricted to admins.
    function removeUser(address account, uint256 typeAccount)
        public
        virtual
        onlyAdminRoot
    {
        if (typeAccount == 0) {
            return revokeRole(USER_ROLE_SUPER_ADMIN, account);
        } else if (typeAccount == 1) {
            return revokeRole(USER_ROLE_ADMIN, account);
        } else if (typeAccount == 2) {
            return revokeRole(USER_ROLE_AMBASSADOR, account);
        } else if (typeAccount == 3) {
            return revokeRole(USER_ROLE_USER, account);
        }
    }

    /// @dev Remove oneself from the admin role.
    function renounceAdmin() public virtual {
        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
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
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title Administered
 * @notice Implements Admin and User roles.
 */
contract SoftAdministered is
    Context
{

    /// @dev Wallet Access Struct
    struct WalletAccessStruct {
        address wallet;
        bool active;
    }

    /// @dev Mapping of Wallet Acces
    mapping(address => WalletAccessStruct) _walletAddressAccessList;

    /// @dev Owner
    address private _owner;

    constructor(){
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
     * @dev Throws if called by any account other than the user.
     */
    modifier onlyUser() {
        require(hasRole( _msgSender()), "Ownable: caller is not the user");
        _;
    }


    /**
     * @dev Throws if called by any account other than the user or owner
     */
    modifier onlyUserOrOwner(){
        require(
            (owner() == _msgSender()) || hasRole(_msgSender()), 
            "Ownable: caller is not valid"
        );
        _;
    }


    /// @dev Add `root` to the admin role as a member.
    function addRole(address _wallet)
        public virtual onlyOwner
    {
        if(!hasRole(_wallet)){
            _walletAddressAccessList[_wallet] = WalletAccessStruct(_wallet, true);
        }
    }

    /// @dev Revoke user role
    function revokeRole(address _wallet)
        public virtual onlyOwner
    {
        if(hasRole(_wallet)){
            _walletAddressAccessList[_wallet].active = false;
        }
    }


    /**
     * @dev Check if wallet address has already role
     */
    function hasRole(address _wallet)
        public view virtual returns (bool)
    {
        return _walletAddressAccessList[_wallet].active;
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) 
        internal virtual 
    {
        _owner = newOwner;
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) 
        public virtual onlyOwner 
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
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

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IPropertyToken {

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function mintReserved(address _address, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface for Contract Transactions
 */
interface IOracle {

    /**
     * @dev Get USD Price of token
     * @param _token                                                Token address
     * @return uint256                                              USD Price of token
     */
    function getUSDPrice(address _token) external view returns (uint256);

    /**
     * @dev Get last price of token
     * @param _oracle                                               Oracle address
     * @param _decimals                                             Decimals of token
     * @return uint256                                              Price of token
     */
    function getLatestPrice(
        address _oracle, 
        uint256 _decimals
    ) external view returns (uint256);

    /**
     * @dev Parse amount token from USD
     * @param _amount                                               Amount of token
     * @param _token                                                Token address   
     * @return uint256                                              Amount in tokens
     */
    function parseAmountFromUSD(
        uint256 _amount,
        address _token
    ) external view returns (uint256);

    /**
     * @dev Parse amount token to USD
     * @param _amount                                               Amount of token
     * @param _token                                                Token address   
     * @return uint256                                              Amount in USD
     */
    function parseAmountToUSD(
        uint256 _amount,
        address _token
    ) external view returns (uint256);

    /**
     * @notice Parse amount to 18 decimals
     * @dev Parse amount to 18 decimals
     * @param _amount                           Amount to convert   
     * @param _decimal                          Decimal to use convert
     */
    function transformAmountTo18Decimal(
        uint256 _amount, 
        uint256 _decimal
    ) external view returns (uint256);

}