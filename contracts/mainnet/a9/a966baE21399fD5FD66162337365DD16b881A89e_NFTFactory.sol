// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
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
pragma solidity 0.8.4;

interface IDepositBox {
    function initialize(address, uint256, address) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

interface IMembershipNFT {
    function ownerOf(uint256) external view returns (address);
    function belongsTo(address) external view returns (uint256);
    function tier(uint256) external view returns(uint256);
    function issueNFT(address, string memory) external returns (uint256);
    function changeURI(uint256, string memory) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IRebaser {

  function getPositiveEpochCount() external view returns (uint256);
  function getBlockForPositiveEpoch(uint256) external view returns (uint256);
  function getDeltaForPositiveEpoch(uint256) external view returns (uint256);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IReferralHandler {
    function initialize(address, address, address, uint256) external;
    function setTier(uint256 _tier) external;
    function setDepositBox(address) external;
    function checkExistence(uint256, address) external view returns (address);
    function coupledNFT() external view returns (address);
    function referredBy() external view returns (address);
    function ownedBy() external view returns (address);
    function getTier() external view returns (uint256);
    function getTransferLimit() external view returns(uint256);
    function remainingClaims() external view returns (uint256);
    function updateReferralTree(uint256 depth, uint256 NFTtier) external;
    function addToReferralTree(uint256 depth, address referred, uint256 NFTtier) external;
    function mintForRewarder(address recipient, uint256 amount ) external;
    function alertFactory(uint256 reward, uint256 timestamp) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./interfaces/IMembershipNFT.sol";
import "./interfaces/IReferralHandler.sol";
import "./interfaces/IDepositBox.sol";
import "./interfaces/IRebaserNew.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";

contract NFTFactory {

    address public admin;
    address public tierManager;
    address public taxManager;
    address public rebaser;
    address public token;
    address public handlerImplementation;
    address public depositBoxImplementation;
    address public rewarder;
    mapping(uint256 => address) NFTToHandler;
    mapping(address => uint256) HandlerToNFT;
    mapping(uint256 => address) NFTToDepositBox;
    mapping(address => bool) handlerStorage;
    mapping(address => uint256) claimedEpoch;
    IMembershipNFT public NFT;
    string public tokenURI;

    event NewAdmin(address oldAdmin, address newAdmin);
    event NewURI(string OldTokenURI,string NewTokenURI);
    event NewRewarder(address oldRewarder, address newRewarder);
    event NewNFT(address oldNFT, address NewNFT);
    event NewRebaser(address oldRebaser, address newRebaser);
    event NewToken(address oldToken, address newToken);
    event NewTaxManager(address oldTaxManager, address newTaxManager);
    event NewTierManager(address oldTierManager, address newTierManager);

    event NewIssuance(uint256 id, address handler, address depositBox);
    event LevelChange(address handler, uint256 oldTier, uint256 newTier);
    event SelfTaxClaimed(address indexed handler, uint256 amount, uint256 timestamp);
    event RewardClaimed(address indexed handler, uint256 amount, uint256 timestamp);
    event DepositClaimed(address indexed handler, uint256 amount, uint256 timestamp);

    modifier onlyAdmin() { // Change this to a list with ROLE library
        require(msg.sender == admin, "only admin");
        _;
    }

    constructor(address _handlerImplementation, address _depositBoxImplementation, string memory _tokenURI) {
        admin = msg.sender;
        handlerImplementation = _handlerImplementation;
        depositBoxImplementation = _depositBoxImplementation;
        tokenURI = _tokenURI;
    }

    function getHandlerForUser(address user) external view returns (address) {
        uint256 tokenID = NFT.belongsTo(user);
        if(tokenID != 0) // Incase user holds no NFT
            return NFTToHandler[tokenID];
        return address(0);
    }

    function getHandler(uint256 tokenID) external view returns (address) {
        return NFTToHandler[tokenID];
    }

    function getDepositBox(uint256 tokenID) external view returns (address) {
        return NFTToDepositBox[tokenID];
    }

    function isHandler(address _handler) public view returns (bool) {
        return handlerStorage[_handler];
    }

    function addHandler(address _handler) public onlyAdmin { // For adding handlers for Staking pools and Protocol owned Pools
        handlerStorage[_handler] = true;
    }

    function alertLevel(uint256 oldTier, uint256 newTier) external { // All the handlers notify the Factory incase there is a change in levels
        require(isHandler(msg.sender) == true);
        emit LevelChange(msg.sender, oldTier, newTier);
    }

    function alertSelfTaxClaimed(uint256 amount, uint256 timestamp) external { // All the handlers notify the Factory when the claim self tax
        require(isHandler(msg.sender) == true);
        emit SelfTaxClaimed(msg.sender, amount, timestamp);
    }

    function alertReferralClaimed(uint256 amount, uint256 timestamp) external { // All the handlers notify the Factory when the claim referral Reward
        require(isHandler(msg.sender) == true);
        emit RewardClaimed(msg.sender, amount, timestamp);
    }

    function alertDepositClaimed(uint256 amount, uint256 timestamp) external { // All the handlers notify the Factory when the claim referral Reward
        require(isHandler(msg.sender) == true);
        emit DepositClaimed(msg.sender, amount, timestamp);
    }


    function getRebaser() external view returns(address) {
        return rebaser;  // Get address of the Rebaser contract
    }

    function getAdmin() external view returns(address) {
        return admin;
    }

    function getToken()  external view returns(address){
        return token;
    }

    function getTaxManager() external view returns(address) {
        return taxManager;
    }

    function getRewarder() external view returns(address) {
        return rewarder;
    }

    function getTierManager() external view returns(address) {
        return tierManager;
    }

    function getEpoch(address user) external view returns (uint256) {
        return claimedEpoch[user];
    }

    function setAdmin(address account) public onlyAdmin {
        address oldAdmin = admin;
        admin = account;
        emit NewAdmin(oldAdmin, account);
    }

    function setDefaultURI(string memory _tokenURI) onlyAdmin public {
        string memory oldURI = tokenURI;
        tokenURI = _tokenURI;
        emit NewURI(oldURI, _tokenURI);
    }

    function setRewarder(address _rewarder) onlyAdmin public {
        address oldRewarder = rewarder;
        rewarder = _rewarder;
        emit NewRewarder(oldRewarder, _rewarder);
    }

    function setNFTAddress(address _NFT) onlyAdmin external {
        address oldNFT = address(NFT);
        NFT = IMembershipNFT(_NFT); // Set address of the NFT contract
        emit NewNFT(oldNFT, _NFT);
    }

    function setRebaser(address _rebaser) onlyAdmin external {
        address oldRebaser = rebaser;
        rebaser = _rebaser; // Set address of the Rebaser contract
         emit NewRebaser(oldRebaser, _rebaser);
    }

    function setToken(address _token) onlyAdmin external {
        address oldToken = token;
        token = _token; // Set address of the Token contract
        emit NewToken(oldToken, _token);
    }

    function setTaxManager(address _taxManager) onlyAdmin external {
        address oldManager = taxManager;
        taxManager = _taxManager;
        emit NewTaxManager(oldManager, _taxManager);
    }

    function setTierManager(address _tierManager) onlyAdmin external {
        address oldManager = tierManager;
        tierManager = _tierManager;
        emit NewTierManager(oldManager, _tierManager);
    }

    function registerUserEpoch(address user) external {
        require(msg.sender == address(NFT));
        uint256 epoch = IRebaser(rebaser).getPositiveEpochCount();
        if(claimedEpoch[user] == 0)
            claimedEpoch[user] = epoch;
    }

    function updateUserEpoch(address user, uint256 epoch) external {
        require(msg.sender == rewarder);
        claimedEpoch[user] = epoch;
    }

    function mint(address referrer) external returns (address) { //Referrer is address of NFT handler of the guy above
        uint256 nftID = NFT.issueNFT(msg.sender, tokenURI);
        uint256 epoch = IRebaser(rebaser).getPositiveEpochCount(); // The handlers need to only track positive rebases
        IReferralHandler handler = IReferralHandler(Clones.clone(handlerImplementation));
        require(address(handler) != referrer, "Cannot be its own referrer");
        require(handlerStorage[referrer] == true || referrer == address(0), "Referrer should be a valid handler");
        handler.initialize(token, referrer, address(NFT), nftID);
        if(claimedEpoch[msg.sender] == 0)
            claimedEpoch[msg.sender] = epoch;
        IDepositBox depositBox =  IDepositBox(Clones.clone(depositBoxImplementation));
        depositBox.initialize(address(handler), nftID, token);
        handler.setDepositBox(address(depositBox));
        NFTToHandler[nftID] = address(handler);
        NFTToDepositBox[nftID] = address(depositBox);
        HandlerToNFT[address(handler)] = nftID;
        handlerStorage[address(handler)] = true;
        handlerStorage[address(depositBox)] = true; // Required to allow it fully transfer the collected rewards without limit
        addToReferrersAbove(1, address(handler));
        emit NewIssuance(nftID, address(handler), address(depositBox));
        return address(handler);
    }

    //TODO: Refactor reuable code
    function mintToAddress(address referrer, address recipient, uint256 tier) external onlyAdmin returns (address) { //Referrer is address of NFT handler of the guy above
        uint256 nftID = NFT.issueNFT(recipient, tokenURI);
        uint256 epoch = IRebaser(rebaser).getPositiveEpochCount(); // The handlers need to only track positive rebases
        IReferralHandler handler = IReferralHandler(Clones.clone(handlerImplementation));
        require(address(handler) != referrer, "Cannot be its own referrer");
        require(handlerStorage[referrer] == true || referrer == address(0), "Referrer should be a valid handler");
        handler.initialize(token, referrer, address(NFT), nftID);
        if(claimedEpoch[recipient] == 0)
            claimedEpoch[recipient] = epoch;
        IDepositBox depositBox =  IDepositBox(Clones.clone(depositBoxImplementation));
        depositBox.initialize(address(handler), nftID, token);
        handler.setDepositBox(address(depositBox));
        NFTToHandler[nftID] = address(handler);
        NFTToDepositBox[nftID] = address(depositBox);
        HandlerToNFT[address(handler)] = nftID;
        handlerStorage[address(handler)] = true;
        handlerStorage[address(depositBox)] = true; // Required to allow it fully transfer the collected rewards without limit
        addToReferrersAbove(1, address(handler));
        handler.setTier(tier);
        emit NewIssuance(nftID, address(handler), address(depositBox));
        return address(handler);
    }

    function addToReferrersAbove(uint256 _tier, address _handler) internal {
        if(_handler != address(0)) {
            address first_ref = IReferralHandler(_handler).referredBy();
            if(first_ref != address(0)) {
                IReferralHandler(first_ref).addToReferralTree(1, _handler, _tier);
                address second_ref = IReferralHandler(first_ref).referredBy();
                if(second_ref != address(0)) {
                    IReferralHandler(second_ref).addToReferralTree(2, _handler, _tier);
                    address third_ref = IReferralHandler(second_ref).referredBy();
                    if(third_ref != address(0)) {
                        IReferralHandler(third_ref).addToReferralTree(3, _handler, _tier);
                        address fourth_ref = IReferralHandler(third_ref).referredBy();
                        if(fourth_ref != address(0))
                            IReferralHandler(fourth_ref).addToReferralTree(4, _handler, _tier);
                    }
                }
            }
        }
    }
}