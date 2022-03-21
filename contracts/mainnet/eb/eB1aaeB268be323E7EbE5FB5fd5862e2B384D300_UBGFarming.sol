//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

struct FarmingData {
    address owner;
    uint256 amount;
    uint256 startTime;
    uint8 action; // 0: add farm, 1: claim, 2: stop
}

struct FarmingPack {
    uint256 id;
    address tokenAddress; // farming token address
    uint256 minFarm; // 9 decimals for UBG, 18 for others.
    uint256 interestSec; // interest per second, 9 decimals
    uint256 farmingType; // 0: has end, 1: endless
    uint256 endTime; // time to end, 0 mean endless
    uint256 commission1; // per 10000
    uint256 commission2; // per 10000
    uint256 commission3; // per 10000
    uint256 commission4; // per 10000
    uint256 commission5; // per 10000
    bool enabled;
}

contract UBGFarming is Ownable, Pausable {
    using SafeERC20 for IERC20;

    // ubg contract
    IERC20 public immutable ubgContract;

    string public name;

    address public systemAddress;
    address public withdrawAddress;

    // purchase options pack
    FarmingPack[] public packs;

    // total paid amount of a farm
    mapping(uint256 => uint256) public farmPaidAmount;

    // store state of joining any pack farming data
    mapping(address => bool) public joinedPack;

    // store user who is able to redeem
    mapping(address => bool) public ableToRedeem;

    // mapping pack id => time amount array value
    mapping(uint256 => FarmingData[]) public farmHistory;

    // mapping pack id => farm amount
    mapping(uint256 => uint256) public farmAmount;

    // number of farming users
    uint256 public farmingUsers;

    // mapping address => commission amount
    mapping(address => uint256) public comissionAmount;

    // mapping pack id => user address => interest claimed
    mapping(uint256 => mapping(address => uint256)) public claimed;

    // reference mapping
    mapping(address => address) private refMap;

    // seeked time
    uint256 public seekedTime;

    // mapping pack id => closed
    mapping(uint256 => bool) public packClosed;

    // events
    event WithdrawAllBNB(address sender, address to);
    event WithdrawUBG(address sender, address to, uint256 amount);
    event ChangeSystemAddress(address sender, address newAddress);
    event PayCommission(
        uint256 farmId,
        address buyerAddress,
        address refAddress,
        uint256 amount
    );
    event ClaimInterest(address sender, uint256 farmId, uint256 interest);
    event Claim(
        address sender,
        uint256 farmId,
        uint256 totalAmount,
        uint256 interest
    );
    event Farm(
        address sender,
        uint256 farmId,
        uint256 amount,
        uint256 startTime
    );

    // ------------ CONSTRUCTORS ------------ //
    constructor(
        address _ownerAddress,
        address _ubgTokenAddress,
        address _systemAddress,
        address _withdrawAddress
    ) {
        _transferOwnership(_ownerAddress);
        ubgContract = IERC20(_ubgTokenAddress);
        systemAddress = _systemAddress;
        withdrawAddress = _withdrawAddress;
        name = "UBGFarming";
    }

    // ------------ EXTERNAL FUNCTIONS ------------ //
    // OWNER: Add Packs
    function addPack(
        uint256 id,
        address tokenAddress, // farming token address
        uint256 minFarm, // 9 decimals for UBG, 18 for others.
        uint256 interestSec, // interest per second
        uint256 farmingType, // 0: has end, 1: endless
        uint256 duration, // duration time til to end, 0 mean endless
        uint256 commission1, // per 10000
        uint256 commission2, // per 10000
        uint256 commission3, // per 10000
        uint256 commission4, // per 10000
        uint256 commission5, // per 10000
        bool enabled
    ) external onlyOwner {
        require(id > 0, "UBG:INVALID_PACK_ID");
        (, FarmingPack memory pack) = getPack(id);
        require(pack.id == 0, "UBG:EXIST_PACK_ID");

        FarmingPack memory newPack = FarmingPack(
            id,
            tokenAddress,
            minFarm,
            interestSec,
            farmingType,
            farmingType == 1 ? 0 : _getBlockTimestamp() + duration,
            commission1,
            commission2,
            commission3,
            commission4,
            commission5,
            enabled
        );
        packs.push(newPack);
    }

    // OWNER: Modify existing pack
    function modifyPack(
        uint256 id,
        uint256 minFarm, // 9 decimals for UBG, 18 for others.
        uint256 interestSec, // interest per second
        uint256 commission1, // per 10000
        uint256 commission2, // per 10000
        uint256 commission3, // per 10000
        uint256 commission4, // per 10000
        uint256 commission5, // per 10000
        bool enabled
    ) external onlyOwner {
        require(!packClosed[id], "UBG:PACK_CLOSED");
        (uint256 index, FarmingPack memory pack) = getPack(id);
        require(pack.id != 0, "UBG:NOT_EXIST_PACK_ID");
        packs[index] = FarmingPack(
            pack.id,
            pack.tokenAddress,
            minFarm,
            interestSec,
            pack.farmingType,
            pack.endTime,
            commission1,
            commission2,
            commission3,
            commission4,
            commission5,
            enabled
        );
    }

    // OWNER: enable/disable pack
    function changePackStatus(uint256 id, bool enabled) external onlyOwner {
        require(!packClosed[id], "UBG:PACK_CLOSED");
        (uint256 index, FarmingPack memory pack) = getPack(id);
        require(pack.id != 0, "UBG:NOT_EXIST_PACK_ID");
        packs[index] = FarmingPack(
            pack.id,
            pack.tokenAddress,
            pack.minFarm,
            pack.interestSec,
            pack.farmingType,
            pack.endTime,
            pack.commission1,
            pack.commission2,
            pack.commission3,
            pack.commission4,
            pack.commission5,
            enabled
        );
    }

    // OWNER: close pack
    function closePack(uint256 id) external onlyOwner {
        require(!packClosed[id], "UBG:PACK_CLOSED");
        (uint256 index, FarmingPack memory pack) = getPack(id);
        require(pack.id != 0, "UBG:NOT_EXIST_PACK_ID");
        packs[index].enabled = false;
        packClosed[pack.id] = true;
        if (pack.farmingType == 1) {
            // close endless farm
            FarmingData memory farmData = FarmingData(
                msg.sender,
                0,
                _getBlockTimestamp(),
                2 // close pack
            );
            farmHistory[pack.id].push(farmData);
        }
    }

    // OWNER: change sytem address
    function changeSystemAddress(address _systemAddress) external onlyOwner {
        systemAddress = _systemAddress;
        emit ChangeSystemAddress(msg.sender, _systemAddress);
    }

    // OWNER: add user to redeem
    function changeUserRedeem(address userRedeem, bool allow)
        external
        onlyOwner
    {
        ableToRedeem[userRedeem] = allow;
    }

    // Buy function for whitelisted users
    function farm(
        uint256 _packId,
        uint256 _amount,
        address _refAddress
    ) external returns (bool) {
        require(!packClosed[_packId], "UBG:PACK_CLOSED");
        (, FarmingPack memory pack) = getPack(_packId);
        require(pack.id != 0, "UBG:NOT_EXIST_POOL_ID");
        require(pack.enabled, "UBG:POOL_DISABLED");
        require(_refAddress != msg.sender, "UBG:INVALID_REF_ADDRESS");
        require(_amount >= pack.minFarm, "UBG:TOO_SMALL_AMOUNT");
        require(
            pack.farmingType == 1 || _getBlockTimestamp() < pack.endTime,
            "UBG:POOL_EXPIRED"
        );

        // TODO: check current balance + owned
        IERC20 tokenContract = IERC20(pack.tokenAddress);

        require(
            tokenContract.balanceOf(msg.sender) >= _amount,
            "UBG:INSUFFIENT_BALANCE_UBG"
        );
        require(
            tokenContract.transferFrom(msg.sender, address(this), _amount),
            "UBG:UBG_TRANSFER_FAILED"
        );

        if (refMap[msg.sender] == address(0)) {
            refMap[msg.sender] = _refAddress;
        }

        FarmingData memory farmData = FarmingData(
            msg.sender,
            _amount,
            _getBlockTimestamp(),
            0
        );
        farmHistory[pack.id].push(farmData);

        // change join pack
        if (!joinedPack[msg.sender]) {
            joinedPack[msg.sender] = true;
            farmingUsers++;
        }

        // update information
        farmAmount[_packId] += _amount;

        emit Farm(msg.sender, _packId, _amount, _getBlockTimestamp());

        return true;
    }

    function transferCommission(
        uint256 farmId,
        address buyer,
        uint256 amount,
        uint256 commission1,
        uint256 commission2,
        uint256 commission3,
        uint256 commission4,
        uint256 commission5
    ) internal {
        // find
        address prevAddress = buyer;
        uint256[5] memory commissions = [
            commission1,
            commission2,
            commission3,
            commission4,
            commission5
        ];
        for (uint256 i = 0; i < commissions.length; i++) {
            address ref = refMap[prevAddress];
            uint256 comissionToPay = (commissions[i] * amount) / 10000;
            if (ref == address(0)) {
                // if no more reference, pay more one time for system
                if (comissionToPay > 0) {
                    require(
                        ubgContract.transfer(systemAddress, comissionToPay),
                        "UBG:TRANSFER_COMMISSION_FAILED"
                    );
                    farmPaidAmount[farmId] += comissionToPay;
                    comissionAmount[systemAddress] += comissionToPay;
                    emit PayCommission(
                        farmId,
                        buyer,
                        systemAddress,
                        comissionToPay
                    );
                }
                break;
            }
            if (comissionToPay > 0) {
                if (!validConditionToPayCommission(ref)) {
                    // transfer to system
                    require(
                        ubgContract.transfer(systemAddress, comissionToPay),
                        "UBG:TRANSFER_COMMISSION_FAILED"
                    );
                    farmPaidAmount[farmId] += comissionToPay;
                    comissionAmount[systemAddress] += comissionToPay;
                    emit PayCommission(
                        farmId,
                        buyer,
                        systemAddress,
                        comissionToPay
                    );
                } else {
                    require(
                        ubgContract.transfer(
                            ref,
                            (commissions[i] * amount) / 10000
                        ),
                        "UBG:TRANSFER_COMMISSION_FAILED"
                    );
                    comissionAmount[ref] += comissionToPay;
                    farmPaidAmount[farmId] += comissionToPay;
                    emit PayCommission(farmId, buyer, ref, comissionToPay);
                }
            }
            prevAddress = ref;
        }
    }

    function validConditionToPayCommission(address ref)
        internal
        view
        returns (bool)
    {
        return joinedPack[ref];
    }

    function claimInterest(uint256 _farmId) external returns (bool) {
        (, FarmingPack memory pack) = getPack(_farmId);
        require(pack.id != 0, "UBG:NOT_EXIST_PACK_ID");

        (uint256 interest, ) = calculateFarm(msg.sender, _farmId);
        require(interest > 0, "UBG:ZERO_INTEREST");

        uint256 claimedInterest = claimed[_farmId][msg.sender];
        require(interest > claimedInterest, "UBG:CLAIMED_TOO_MUCH");

        claimed[_farmId][msg.sender] = interest;
        uint256 sendAmount = interest - claimedInterest;
        require(
            ubgContract.transfer(msg.sender, sendAmount),
            "UBG:TRANSFER_UBG_AMOUNT_FAILED"
        );
        farmPaidAmount[_farmId] += sendAmount;
        if (sendAmount > 0) {
            transferCommission(
                pack.id,
                msg.sender,
                sendAmount,
                pack.commission1,
                pack.commission2,
                pack.commission3,
                pack.commission4,
                pack.commission5
            );
        }

        emit ClaimInterest(msg.sender, _farmId, sendAmount);
        return true;
    }

    // Claim Ubg after locking time
    function claim(uint256 _farmId) external returns (bool) {
        (, FarmingPack memory pack) = getPack(_farmId);
        require(pack.id != 0, "UBG:NOT_EXIST_PACK_ID");
        require(
            pack.farmingType == 1 || pack.endTime <= _getBlockTimestamp(),
            "UBG:POOL_DOESNT_FINISH"
        );

        // calculate interest & total user farm
        (uint256 interest, uint256 totalUserFarm) = calculateFarm(
            msg.sender,
            _farmId
        );
        require(interest > 0, "UBG:ZERO_INTEREST");
        require(totalUserFarm > 0, "UBG:ZERO_POOL_VALUE");

        // add claim to history
        FarmingData memory farmData = FarmingData(
            msg.sender,
            totalUserFarm,
            _getBlockTimestamp(),
            1
        );
        farmHistory[pack.id].push(farmData);

        // release interest
        uint256 sendValue = 0;
        if (interest > claimed[_farmId][msg.sender]) {
            sendValue = interest - claimed[_farmId][msg.sender];
            require(
                ubgContract.balanceOf(address(this)) >= sendValue,
                "UBG:CONTRACT_BALANCE_NOT_ENOUGH"
            );
            require(
                ubgContract.transfer(msg.sender, sendValue),
                "UBG:TRANSFER_INTEREST_AMOUNT_FAILED"
            );
            farmPaidAmount[_farmId] += sendValue;
        }

        // release origin farm value
        require(
            IERC20(pack.tokenAddress).transfer(msg.sender, totalUserFarm),
            "UBG:TRANSFER_FARM_AMOUNT_FAILED"
        );

        // reset claimed interest
        claimed[_farmId][msg.sender] = 0;

        // release comission
        if (sendValue > 0) {
            transferCommission(
                pack.id,
                msg.sender,
                sendValue,
                pack.commission1,
                pack.commission2,
                pack.commission3,
                pack.commission4,
                pack.commission5
            );
        }

        // update farm amount
        farmAmount[pack.id] -= totalUserFarm;

        emit Claim(msg.sender, _farmId, totalUserFarm, sendValue);
        return true;
    }

    // Redeem
    function redeem(uint256 _farmId, uint256 _amount) external returns (bool) {
        require(_amount > 0, "UBG:ZERO_AMOUNT");
        (, FarmingPack memory pack) = getPack(_farmId);
        require(pack.id != 0, "UBG:NOT_EXIST_PACK_ID");
        require(ableToRedeem[msg.sender], "UBG:NOT_ABLE_TO_REDEEM");

        // calculate interest & total user farm
        (uint256 interest, uint256 totalUserFarm) = calculateFarm(
            msg.sender,
            _farmId
        );
        require(interest > 0, "UBG:ZERO_INTEREST");
        require(totalUserFarm >= _amount, "UBG:NOT_ENOUGH_VALUE");

        // add claim to history
        FarmingData memory farmData = FarmingData(
            msg.sender,
            _amount,
            _getBlockTimestamp(),
            1
        );
        farmHistory[pack.id].push(farmData);

        // release interest
        if (interest > claimed[_farmId][msg.sender]) {
            uint256 sendAmount = interest - claimed[_farmId][msg.sender];
            require(
                ubgContract.transfer(msg.sender, sendAmount),
                "UBG:TRANSFER_UBG_AMOUNT_FAILED"
            );
            farmPaidAmount[_farmId] += sendAmount;
        }

        // release origin farm value
        require(
            IERC20(pack.tokenAddress).transfer(msg.sender, _amount),
            "UBG:TRANSFER_FARM_AMOUNT_FAILED"
        );

        // decrease farm amount
        farmAmount[_farmId] -= _amount;

        // reset claimed interest
        claimed[_farmId][msg.sender] = 0;

        return true;
    }

    function calculateFarm(address user_address, uint256 _farmId)
        public
        view
        returns (uint256, uint256)
    {
        (, FarmingPack memory pack) = getPack(_farmId);
        require(pack.id != 0, "UBG:NOT_EXIST_PACK_ID");

        uint256 interest = 0;
        uint256 totalAmount = 0;
        uint256 totalUserFarm = 0;
        uint256 cTime = 0;
        uint256 endTime = pack.endTime;

        FarmingData[] memory farmHis = farmHistory[_farmId];
        for (uint256 i = 0; i < farmHis.length; i++) {
            FarmingData memory farmItem = farmHis[i];
            bool calculateInterest = (farmItem.startTime < pack.endTime ||
                pack.farmingType == 1 ||
                pack.farmingType == 2);
            // add farm action
            if (totalUserFarm > 0 && calculateInterest) {
                interest +=
                    (pack.interestSec *
                        (farmItem.startTime - cTime) *
                        totalUserFarm) /
                    totalAmount;
            }

            if (farmItem.action == 0) {
                if (calculateInterest) {
                    cTime = farmItem.startTime;
                    totalAmount += farmItem.amount;
                }
                if (farmItem.owner == user_address) {
                    totalUserFarm += farmItem.amount;
                }
            } else if (farmItem.action == 1) {
                // claim action
                if (calculateInterest) {
                    cTime = farmItem.startTime;
                    totalAmount -= farmItem.amount;
                }
                if (farmItem.owner == user_address) {
                    totalUserFarm -= farmItem.amount;
                    interest = 0;
                }
            } else if (farmItem.action == 2) {
                // close action
                if (calculateInterest) {
                    cTime = farmItem.startTime;
                }
                endTime = farmItem.startTime;
            }
        }
        uint256 lTime = _getBlockTimestamp();
        if (pack.farmingType == 0 && lTime > endTime) {
            lTime = endTime;
        }
        if (pack.farmingType == 1 && endTime != 0 && lTime > endTime) {
            lTime = endTime;
        }
        if (totalUserFarm > 0 && totalAmount > 0) {
            interest +=
                (pack.interestSec * (lTime - cTime) * totalUserFarm) /
                totalAmount;
        }
        return (interest, totalUserFarm);
    }

    // Withdraw contract value to address
    function withdrawAllBNB() external onlyOwner returns (bool) {
        // check conditions
        require(address(this).balance > 0, "UBG:NO_BALANCE_TO_WITHDRAW");

        emit WithdrawAllBNB(msg.sender, withdrawAddress);

        // withdraw to address
        return payable(withdrawAddress).send(address(this).balance);
    }

    function seekTime(uint256 _seekedTime) external onlyOwner {
        seekedTime += _seekedTime;
    }

    // ------------ PUBLIC FUNCTIONS ------------ //
    // Get pack with id
    function getPack(uint256 _id)
        private
        view
        returns (uint256 index, FarmingPack memory)
    {
        for (uint256 i = 0; i < packs.length; i++) {
            if (packs[i].id == _id) {
                return (i, packs[i]);
            }
        }
        return (
            0,
            FarmingPack(0, address(0), 0, 0, 0, 0, 0, 0, 0, 0, 0, false)
        );
    }

    function getPackInfo(uint256 _id) public view returns (FarmingPack memory) {
        (, FarmingPack memory pack) = getPack(_id);
        return pack;
    }

    // Get current balance of this contract
    function getUbgBalance() public view returns (uint256) {
        return ubgContract.balanceOf(address(this));
    }

    function _getBlockTimestamp() public view virtual returns (uint256) {
        return seekedTime + block.timestamp;
    }

    function packsLength() public view returns (uint256) {
        return packs.length;
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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