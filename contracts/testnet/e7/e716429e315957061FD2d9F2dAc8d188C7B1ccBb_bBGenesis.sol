// SPDX-License-Identifier: MIT
// 2022 - BabelSwap Team

pragma solidity ^0.8.0;

import {SafeERC20, IERC20} from "./openzeppelin/token/ERC20/SafeERC20.sol";
import {ReentrancyGuard} from "./openzeppelin/security/ReentrancyGuard.sol";
import {INFT} from "./interfaces/INFT.sol";
import {ISwap} from "./interfaces/ISwap.sol";

contract bBGenesis is ReentrancyGuard {
    using SafeERC20 for IERC20;

    INFT public immutable GenesisNFT;
    INFT public immutable GenesisTreeNFT;

    bool public claimIsFreezed;
    bool public isSwapPaused;

    bytes32 internal _root;
    
    address[] internal _Genesis;
    address public immutable admin;

    IERC20 public immutable busd;
    IERC20 public bBMirror;

    uint256 public startTime;
    uint256 public FreezedSwapTime;
    uint256 public immutable finalTime;

    uint256 public constant limit = 20000;
    uint256 public constant maxTime = 2 days;
    uint256 private _totalRewards;
    uint256 private counting;

    uint256 private RewardAmountPack1 = 5e18;
    uint256 private RewardAmountPack2 = 50e18;
    uint256 private RewardAmountPack3 = 275e18;

    mapping(address => bool) public isOnGenesis;
    mapping(address => bool) private hasClaimed;
    mapping(address => uint256) private _userChoise;
    mapping(address => uint256) private index;
    mapping(uint256 => address) private _index;

    event CreateTree(bytes32 root);
    event AddToGenesis(address wallet, uint256 pack);
    event PauseSwap(bool isSwapPaused);
    event SetMirror(address bBMirror);
    event SetFreeze(uint256 FreezedTimestamp, bool claimIsFreezed);

    constructor (IERC20 _token, address _admin, INFT _nftGenesis, INFT _nftGenesisTree) {
        busd = _token;
        admin = _admin;
        GenesisNFT = _nftGenesis;
        GenesisTreeNFT = _nftGenesisTree;

        startTime = block.timestamp;
        finalTime = startTime + maxTime;
        claimIsFreezed = true;
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert("Only Admin");
        _;
    }

    modifier afterThis() {
        if (isGenesisOpen()) revert("Genesis is open");
        _;
    }

    function isGenesisOpen() public view returns (bool) {
        return block.timestamp > finalTime || _Genesis.length == limit ? false : true;
    }

    function isClaimable() internal view returns (bool) {
        return !isGenesisOpen() && !claimIsFreezed ? true : false; 
    }

    function Genesis() public view returns (bytes32) {
        return (_root);
    }

    function GenesisLength() public view returns (uint256) {
        return _Genesis.length;
    }

    function totalLiquidity() public view returns (uint256) {
        return busd.balanceOf(address(this));
    }

    function totalRewards() public view returns (uint256) {
        return _totalRewards;
    }

    function setMirror(IERC20 _bBMirror) external onlyAdmin {
        bBMirror = _bBMirror;
        emit SetMirror(address(bBMirror));
    }

    function pauseSwap(bool _paused) external onlyAdmin {
        if (!_paused && !isSwapPaused) revert("Swap is not paused");
        if (_paused && isSwapPaused) revert("Swap is already paused");

        isSwapPaused = _paused;
        emit PauseSwap(isSwapPaused);
    }

    function setFreeze(bool _isFreezed) external onlyAdmin afterThis {
        if (!_isFreezed && claimIsFreezed) {
            FreezedSwapTime = block.timestamp + 2 days;
            claimIsFreezed = false;
            emit SetFreeze(FreezedSwapTime, claimIsFreezed);
        }
    }

    function mintRemaining(uint256 amount, bool nft) external onlyAdmin {
        if (nft) {
            if (isGenesisOpen()) revert("Genesis Open");
            GenesisNFT.mintGenesis(admin, amount);
        } 
        else {
            GenesisTreeNFT.mintTree(admin, amount);
        }
    }

    function tree(uint256 _pos) external onlyAdmin view returns (address) {
        if (_pos == 0) revert("1 - 20,000");
        if (_pos > _Genesis.length) revert("pos > length");
        return _index[_pos];
    }

    function arrayOfTree(uint256 _max) external onlyAdmin view returns (address[] memory) {
        if (_max == 0) revert("1 - 20,000");
        if (_max > _Genesis.length) revert("max > length");

        address[] memory result = new address[](_max);

        unchecked {
            for (uint256 i; i<_max; i++) {
                result[i] = _index[i+1];
            }
        }
        return result;
    }

    function SwapTokens(uint256 amount) external nonReentrant returns (bool) {
        if (isSwapPaused) revert("SwapTokens Paused");
        if (FreezedSwapTime > block.timestamp) revert("SwapTokens Frezzed, Wait");
        if (!hasClaimed[msg.sender]) revert("You need to claim first");

        ISwap(address(bBMirror)).swapTokens(msg.sender, amount);
        return true;
    }

    function viewProof() public view returns (bytes32[] memory _proof) {
        uint256 genLen = _Genesis.length;
        bytes32[] memory data = new bytes32[](genLen);

        unchecked {
            for (uint256 i; i < genLen; i++) {
                data[i] = keccak256(abi.encodePacked(_Genesis[i]));
            }

            _proof = getProof(data, index[msg.sender]-1);
        }

        if (verifyProof(_root, _proof, keccak256(abi.encodePacked(msg.sender)))) {
            return _proof;

        } else { revert("Wallet not found on Genesis"); }
    }

    function addToGenesis(address wallet, uint256 pack) external nonReentrant {
        if (!isGenesisOpen()) revert("Genesis Closed");
        if (wallet.code.length != 0) revert("Contracts not Allowed");
        if (msg.sender != tx.origin) revert("Proxy Contracts not Allowed");

        uint256 deposit;
        uint256 finalbBRewards;

        if (pack == 1) {
            deposit = 10e18;
            finalbBRewards = RewardAmountPack1;
        } else if (pack == 2) {
            deposit = 100e18;
            finalbBRewards = RewardAmountPack2;
        } else if (pack == 3) {
            deposit = 500e18;
            finalbBRewards = RewardAmountPack3;
        } else revert("Invalid Pack");

        busd.safeTransferFrom(msg.sender, address(this), deposit);
        _userChoise[wallet] = pack;

        unchecked {
            if (!isOnGenesis[wallet]) {
                index[wallet] = _Genesis.length + 1;
                _index[index[wallet]] = wallet;
                _Genesis.push(wallet);
                isOnGenesis[wallet] = true;
                GenesisNFT.mintGenesis(wallet, 1);
                _totalRewards += finalbBRewards;

                if (pack == 3) {
                    if (counting + 1 <= 100) {
                        GenesisTreeNFT.mintTree(wallet, 1);
                        counting += 1;
                    }
                }
            }
        }
        emit AddToGenesis(wallet, pack);
    }

    function createTree() external onlyAdmin afterThis {
        uint256 genLen = _Genesis.length;
        bytes32[] memory data = new bytes32[](genLen);

        unchecked {
            for (uint256 i; i < genLen; i++) {
                data[i] = keccak256(abi.encodePacked(_Genesis[i]));
            }
        }

        _root = getRoot(data);
        emit CreateTree(_root);
    }

    function claim(bytes32[] memory _proof) external nonReentrant {
        address sender = msg.sender;

        if (!isClaimable()) revert("Claim is Freezed, Wait");
        if (hasClaimed[sender]) revert("Already Claimed");

        if (verifyProof(_root, _proof, keccak256(abi.encodePacked(sender)))) {
            hasClaimed[sender] = true;

            if (_userChoise[sender] == 1)
                bBMirror.safeTransfer(sender, RewardAmountPack1);
            else if (_userChoise[sender] == 2)
                bBMirror.safeTransfer(sender, RewardAmountPack2);
            else if (_userChoise[sender] == 3)
                bBMirror.safeTransfer(sender, RewardAmountPack3);

        } else { revert("Wallet not found on Genesis"); }
    }

    function withdraw(address _token) external onlyAdmin {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance > 0, "No funds");
        IERC20(_token).safeTransfer(admin, balance);
    }

    /// @notice Nascent, simple, kinda efficient (and improving!) Merkle proof generator and verifier
    /// @dev dmfxyz
    /// https://github.com/dmfxyz/murky
    /// @dev Note Xor Based "Merkle" Tree

    function hashLeafPairs(bytes32 left, bytes32 right) internal pure returns (bytes32 _hash) {
        // saves a few gas lol
        assembly {
            mstore(0x0, xor(left,right))
           _hash := keccak256(0x0, 0x20)
        }
    }
    
    function verifyProof(bytes32 root, bytes32[] memory proof, bytes32 valueToProve) internal pure returns (bool) {
        // proof length must be less than max array size
        bytes32 rollingHash = valueToProve;
        uint256 length = proof.length;
        unchecked {
            for(uint256 i; i < length; ++i){
                rollingHash = hashLeafPairs(rollingHash, proof[i]);
            }
        }
        return root == rollingHash;
    }

    function getRoot(bytes32[] memory data) internal pure returns (bytes32) {
        while (data.length > 1) {
            data = hashLevel(data);
        }
        return data[0];
    }

    function getProof(bytes32[] memory data, uint256 node) internal pure returns (bytes32[] memory) {
        uint256 pos;
        // The size of the proof is equal to the ceiling of log2(numLeaves)
        bytes32[] memory result = new bytes32[](log2ceilBitMagic(data.length));

        // Two overflow risks: node, pos
        // node: max array size is 2**256-1. Largest index in the array will be 1 less than that. Also,
        // for dynamic arrays, size is limited to 2**64-1
        // pos: pos is bounded by log2(data.length), which should be less than type(uint256).max
        while(data.length > 1) {
            unchecked {
                if(node & 0x1 == 1) {
                    result[pos] = data[node - 1];
                } 
                else if (node + 1 == data.length) {
                    result[pos] = bytes32(0);  
                } 
                else {
                    result[pos] = data[node + 1];
                }
                ++pos;
                node /= 2;
            }
            data = hashLevel(data);
        }
        return result;
    }

    ///@dev function is internal to prevent unsafe data from being passed
    function hashLevel(bytes32[] memory data) internal pure returns (bytes32[] memory) {
        bytes32[] memory result;

        // Function is internal, and all internal callers check that data.length >=2.
        // Underflow is not possible as lowest possible value for data/result index is 1
        // overflow should be safe as length is / 2 always. 
        unchecked {
            uint256 length = data.length;
            if (length & 0x1 == 1){
                result = new bytes32[](length / 2 + 1);
                result[result.length - 1] = hashLeafPairs(data[length - 1], bytes32(0));
            } else {
                result = new bytes32[](length / 2);
        }
        // pos is upper bounded by data.length / 2, so safe even if array is at max size
            uint256 pos;
            for (uint256 i; i < length-1; i+=2){
                result[pos] = hashLeafPairs(data[i], data[i+1]);
                ++pos;
            }
        }
        return result;
    }

    /// Original bitmagic adapted from https://github.com/paulrberg/prb-math/blob/main/contracts/PRBMath.sol
    /// @dev Note that x assumed > 1
    function log2ceilBitMagic(uint256 x) internal pure returns (uint256){
        if (x <= 1) {
            return 0;
        }
        uint256 msb;
        uint256 _x = x;
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            msb += 1;
        }

        uint256 lsb = (~_x + 1) & _x;
        if ((lsb == _x) && (msb > 0)) {
            return msb;
        } else {
            return msb + 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "./IERC20.sol";
import {Address} from "../../utils/Address.sol";

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
        IERC20 token,
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// 2022 - BabelSwap Team

pragma solidity ^0.8.0;

interface INFT {
    function mintGenesis(address to, uint256 amount) external;
    function mintTree(address to, uint256 amount) external;
    function isHolder(address wallet) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// BabelSwap Team

pragma solidity ^0.8.0;

interface ISwap {
    function swapTokens(address to, uint256 amount) external;
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function totalBurned() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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