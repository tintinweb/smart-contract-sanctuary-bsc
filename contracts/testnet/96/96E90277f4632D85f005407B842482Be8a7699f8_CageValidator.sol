// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {MultisigValidator} from "./ValidatorBase.sol";
import {IHamsterCage} from "../bridge/HamsterCage.sol";


contract CageValidator is MultisigValidator {

    constructor(address _owner, uint8 sigCount) {
        require(sigCount > 0, "Invalid Signature count");
        requiredSigCount = sigCount;
        owner = _owner;
    }

    function executeTransaction(ExecData memory data, SigECDSA[] memory signatures) public onlySigner {

        require(signatures.length >= requiredSigCount, "CV: Invalid sigcount"); 
        require(!logs[data.eventId], "CV: Already executed");
        require(data.amount > 0 || data.tokenIds.length > 0);
        uint256 standard = 20;

        if (data.amount == 0) {
            require(data.tokenIds.length > 0, "CV: Invalid input");
            standard = 721;
        }

        for (uint256 i = 0; i < signatures.length; i++) {
            require(
                verifySignature(
                    data.eventId,
                    data.sourceChainId,
                    data.sourceToken,
                    data.receiver, 
                    signatures[i]
                ),
                "CV: Invalid Signature"
            );
        }

        logs[data.eventId] = true;

        if (standard == 20) {
            IHamsterCage(_bridge).withdrawERC20(
                data.sourceToken, 
                data.destToken, 
                data.receiver, 
                data.initiator,
                data.amount, 
                data.eventId
            );
        } else {
            IHamsterCage(_bridge).withdrawERC721(
                data.sourceToken, 
                data.destToken, 
                data.receiver, 
                data.initiator,
                data.tokenIds,
                data.eventId
            );
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {HamsterLock} from "../bridge/BridgeBase.sol";
import "../utils/ExtCalls.sol";

contract MultisigValidator is HamsterLock, ExtCalls {

    struct ExecData {
        bytes32 eventId;
        uint256 sourceChainId;
        address sourceToken;
        uint256 destChainId;
        address destToken;
        address initiator;
        address receiver;
        uint256 amount;
        uint256[] tokenIds;
        string[] URIs;
        ExtCalls.TokenInfo tokenInfo;
    }

    struct SigECDSA {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    uint8 internal requiredSigCount;
    address public _bridge;
    mapping(address => bool) public signers;
    mapping(bytes32 => bool) public logs;
    mapping(bytes => bool) private _signatures;

    modifier onlySigner() {
        require(signers[msg.sender], "Validator: Unauthorized signer");
        _;
    }

    function setHamster(address payable hamser) external onlyOwner {
        require(HamsterLock(hamser).isHamsterLock(), "Not Hamser");
        _bridge = hamser;
    }

    function verifySignature(
        bytes32 eventId, 
        uint256 sourceChain,
        address token,
        address receiver, 
        SigECDSA memory signature
    ) internal returns(bool) {

        require(!_signatures[abi.encode(signature)], "Validator: Used signature");
        _signatures[abi.encode(signature)] = true;

        bytes32 _encode = keccak256(
            abi.encodePacked(eventId, sourceChain, token, block.chainid, receiver, _bridge, address(this))
        );

        return signers[ecrecover(_encode, signature.v, signature.r, signature.s)];
    }

    function setSigner(address newSigner, bool status) external onlyOwner {
        if (status) {
            require(newSigner != address(0), "Validator: Invalid Signer");
            require(newSigner != owner, "Validator: Owner cannot be Signer");
            signers[newSigner] = status;
        } else {
            signers[newSigner] = false;
        }
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BridgeBase, IHERC20} from "./BridgeBase.sol";

interface IHamsterCage {

    function withdrawERC20(
        address sourceToken, 
        address token, 
        address to, 
        address initiator, 
        uint256 amount, 
        bytes32 eventId
    ) external;

    function withdrawERC721(
        address sourceToken, 
        address token, 
        address to, 
        address initiator, 
        uint256[] memory tokenIds, 
        bytes32 eventId
    ) external;

    function withdrawEther(address payable to, address initiator, uint256 amount) external;
}


contract HamsterCage is BridgeBase {

    bool private etherEnabled;

    mapping(address => bool) stablecoins;
    mapping(address => bool) allowedTokens;

    constructor(address _owner, address operator, uint256 _hamsterChainId)  {
        owner = _owner;
        operators[operator] = true;
        chainId = block.chainid;
        hamsterChainId = _hamsterChainId;
    }

    modifier onlyAllowed(address token) {
        require(allowedTokens[token], "HamsterCage: Disallowed token");
        _;
    }

    function _checkHamsterEventId(bytes32 eventId, address hamsterToken, address localToken) private {
        require(eventId == _getHamsterEventId(hamsterChainId, hamsterToken, localToken, chainId), "HamsterCage: Invalid event");
        _checkEventId(eventId);
    }

    function isStable(address token) public view returns(bool) {
        return stablecoins[token];
    }

    function setEtherDeposits(bool state) external onlyOwner {
        etherEnabled = state;
    }

    function setHamsterNonce(uint256 sourceChain, address sourceToken, address destToken, uint256 destChain) external onlyOwner {
        bytes32 _hamsterNonce = keccak256(
            abi.encodePacked(
                sourceChain,
                sourceToken,
                destChain,
                destToken
            )
        );
        hamsterNonce[_hamsterNonce] ++;
    }

    function setToken(address token, bool status) external onlyOwner {
        if (status != allowedTokens[token]) {
            allowedTokens[token] = status;
        }
    }

    function adminRebalance(address _tokenIn, address _tokenOut, uint256 amount) external onlyOwner {

        IHERC20 tokenIn = IHERC20(_tokenIn);
        IHERC20 tokenOut = IHERC20(_tokenOut);
        
        uint8 decimalsIn = tokenIn.decimals();
        uint8 decimalsOut = tokenOut.decimals();
        uint256 amountOut = amount;
        
        if (decimalsIn > decimalsOut) {
            amountOut = amount / (10 ** (decimalsIn - decimalsOut));
        } else if (decimalsOut > decimalsIn) {
            amountOut = amount * (10 ** (decimalsOut - decimalsIn));
        }

        tokenIn.transferFrom(msg.sender, address(this), amount);
        tokenOut.transfer(msg.sender, amountOut);
        // emit rebalance
    }

    function depositERC20(
        address token, 
        address to, 
        uint256 amount
    ) 
        external 
        whenUnlocked
        whenNotPaused
        onlyAllowed(token) 
    {
        _depositERC20(token, amount);
        TokenInfo memory metadata = getTokenMetadata(token, false);

        emit ERC20Event(
            DEPOSIT, 
            _getEventId(), 
            msg.sender, 
            nonce,
            token, 
            address(0),
            hamsterChainId,
            to, 
            amount, 
            metadata
        );
    }

    function withdrawERC20(
        address sourceToken, 
        address token, 
        address to, 
        address initiator, 
        uint256 amount, 
        bytes32 eventId
    ) external onlyOperator {

        _checkHamsterEventId(eventId, sourceToken, token);
        bytes32 nonceBytes = _getHamsterNonceBytes(hamsterChainId, sourceToken, token, chainId);
        _withdrawERC20(token, to, amount);
        TokenInfo memory metadata = getTokenMetadata(token, false);

        emit ERC20Event(
            WITHDRAW, 
            eventId, 
            initiator, 
            hamsterNonce[nonceBytes],
            address(0),
            token, 
            chainId,
            to, 
            amount, 
            metadata
        );
    }

    function depositERC721(
        address token, 
        address to, 
        uint256[] memory tokenIds
    ) 
        external 
        whenUnlocked
        whenNotPaused
        onlyAllowed(token)
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _depositERC721(token, tokenIds[i]);
        }
        string[] memory URIs = callTokenURI(token, tokenIds);
        TokenInfo memory metadata = getTokenMetadata(token, false);
        emit ERC721Event(
            DEPOSIT, 
            _getEventId(), 
            msg.sender, 
            nonce,
            token, 
            address(0),
            hamsterChainId,
            to, 
            tokenIds, 
            URIs,
            metadata
        );
    }

    function withdrawERC721(
        address sourceToken, 
        address token, 
        address to, 
        address initiator, 
        uint256[] memory tokenIds, 
        bytes32 eventId
    ) 
        external 
        onlyOperator 
        whenUnlocked
        whenNotPaused
    {

        _checkHamsterEventId(eventId, sourceToken, token);
        bytes32 nonceBytes = _getHamsterNonceBytes(hamsterChainId, sourceToken, token, chainId);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _withdrawERC721(token, to, tokenIds[i]);
        }
        string[] memory URIs = callTokenURI(token, tokenIds);
        TokenInfo memory metadata = getTokenMetadata(token, false);
        emit ERC721Event(
            WITHDRAW, 
            eventId, 
            initiator, 
            hamsterNonce[nonceBytes],
            address(0),
            token, 
            chainId,
            to, 
            tokenIds, 
            URIs,
            metadata
        );
    }

    function depositEther(address to, uint256 amount) external payable whenUnlocked whenNotPaused {
        require(etherEnabled, "HamsterCage: Ether disabled");
        _depositEther(amount);
        emit EtherEvent(DEPOSIT, _getEventId(), msg.sender, nonce, to, amount, hamsterChainId);
    }

    function withdrawEther(
        address payable to, 
        address initiator,
        uint256 amount
    ) external 
        onlyOperator 
        whenUnlocked 
        whenNotPaused
    {
        _withdrawEther(to, amount);
        emit EtherEvent(WITHDRAW, _getEventId(), initiator, 0, to, amount, chainId);
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../tokens/IHERC20.sol";
import "../tokens/IHERC721.sol";
import "../utils/ExtCalls.sol";

import {HamsterLock} from "../access/HamsterLock.sol";
import {SafeHERC20} from "../tokens/SafeHERC20.sol";


abstract contract BridgeBase is HamsterLock, ExtCalls {

    using SafeHERC20 for IHERC20;

    uint256 hamsterChainId;
    uint256 chainId;

    // Mapping of contract nonce
    uint256 nonce;
    // Mapping of executed eventIds 
    mapping(bytes32 => bool) eventIds;
    // Mapping of hamsterChain event nonces from hashed inputs/outputs
    // source chain (hamsterChainId), source token (hamsterToken), destination chain, and dest token
    mapping(bytes32 => uint256) hamsterNonce;

    uint8 constant MINT = 0;
    uint8 constant BURN = 1;
    uint8 constant DEPOSIT = 2;
    uint8 constant WITHDRAW = 3;

    event ERC20Event(
        uint8 indexed _type,
        bytes32 indexed _id,
        address initiator,
        uint256 nonce,
        address indexed sourceToken,
        address destinationToken,
        uint256 destinationChainId,
        address receiver, 
        uint256 amount,
        TokenInfo tokenInfo
    );

    event ERC721Event(
        uint8 indexed _type,
        bytes32 indexed _id,
        address initiator,
        uint256 nonce,
        address indexed sourceToken,
        address destinationToken,
        uint256 destinationChainId,
        address receiver,
        uint256[] tokenIds,
        string[] URIs,
        TokenInfo tokenInfo
    );

    event EtherEvent(
        uint8 indexed _type,
        bytes32 indexed _id,
        address initiator,
        uint256 nonce,
        address receiver,
        uint256 amount,
        uint256 destinationChainId
    );

    function _getNonce() private returns (uint256) {
        nonce ++;
        return nonce;
    }

    function _getHamsterNonceBytes(
        uint256 sourceChain, 
        address sourceToken, 
        address destToken, 
        uint256 destChain
    ) internal pure returns(bytes32) {
        return keccak256(
                abi.encodePacked(
                    sourceChain,
                    sourceToken,
                    destChain,
                    destToken
                )
        );
    }

    function _getHamsterNonce(bytes32 nonceCode) private returns(uint256) {
        hamsterNonce[nonceCode] ++;
        return hamsterNonce[nonceCode];
    }

    function _getTokenMetadata(address token, bool includeDecimals) internal view returns(TokenInfo memory) {
        return(getTokenMetadata(token, includeDecimals));
    }

    function _checkEventId(bytes32 eventId) internal {
        require(!eventIds[eventId], "HB Base: Event executed");
        eventIds[eventId] = true;
    }

    function _getEventId() internal returns(bytes32) {
        return keccak256(
            abi.encodePacked(
                chainId,
                _getNonce()
            )
        );

    }

    function _getHamsterEventId(uint256 sourceChain, address sourceToken, address destToken, uint256 destChain) internal returns(bytes32) {
        bytes32 hamsterNonceCode = _getHamsterNonceBytes(sourceChain, sourceToken, destToken, destChain);
        return keccak256(
                abi.encodePacked(
                    sourceChain,
                    sourceToken,
                    destChain,
                    destToken,
                    _getHamsterNonce(hamsterNonceCode)
                )
        );
    }

    function onERC721Received(address operator, uint256, bytes calldata) external view returns(bytes4) {
        require(operator == address(this), "HB Base: [ERC721] Unauthorized operator");
        return(IHERC721.onERC721Received.selector);
    }

    function _mintERC20(address token, address to, uint256 amount) internal {
        IHERC20(token).mint(to, amount);
    }

    function _depositERC20(address token, uint256 amount) internal {
        require(amount > 0, "HB Base: Invalid amount");
        IHERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    function _withdrawERC20(address token, address to, uint256 amount) internal {
        IHERC20(token).safeTransfer(to, amount);
    }

    function _burnERC20(address token, address from, uint256 amount) internal {
        require(amount > 0, "HB Base: Invalid amount");
        IHERC20(token).burnFrom(from, amount);
    }

    function _mintERC721(address token, address to, uint256 tokenId, string memory uri) internal {
        IHERC721(token).safeMint(to, tokenId, uri);
    }

    function _depositERC721(address token, uint256 tokenId) internal {
        IHERC721(token).safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function _withdrawERC721(address token, address to, uint256 tokenId) internal {
        IHERC721(token).safeTransferFrom(address(this), to, tokenId);
    }

    function _burnERC721(address token, uint256 tokenId) internal {
        IHERC721(token).burnFrom(tokenId);
    }

    function _depositEther(uint256 amount) internal {
        require(msg.value > 0, "HB Base: 0");
        require(msg.value == amount, "HB Base: Ether insufficient amount");
    }

    function _withdrawEther(address payable to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}("");
        require(success, "HB Base: Ether transfer failed");
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


abstract contract ExtCalls {

    struct TokenInfo {
        string name;
        string symbol;
        uint8 decimals;
    }

    string private constant NAME_SIGNATURE = "name()";
    string private constant SYMBOL_SIGNATURE = "symbol()"; 
    string private constant DECIMALS_SIGNATURE = "decimals()";
    string private constant STANDARD_SIGNATURE = "tokenStandard()";

    function getTokenStandard(address token) internal view returns(uint256) {
        return uint256(abi.decode(callMetadata(token, STANDARD_SIGNATURE, false), (uint256)));
    }
    
    function getTokenMetadata(address token, bool includeDecimals) internal view returns(TokenInfo memory) {
        string memory name;
        string memory symbol;
        uint8 decimals;

        if (includeDecimals) {
            decimals = uint8(abi.decode(callMetadata(token, DECIMALS_SIGNATURE, false), (uint8)));
            require(decimals >= 18, "HB Utils: Invalid decimals");
        }
        {
            name = string(callMetadata(token, NAME_SIGNATURE, true));
        }
        {
            symbol = string(callMetadata(token, SYMBOL_SIGNATURE, true));
        }
        return TokenInfo(name, symbol, decimals);
    }

    function callMetadata(address _contract, string memory sig, bool isString) internal view returns (bytes memory) {
        
        (bool success, bytes memory data) = _contract.staticcall(abi.encodeWithSignature(sig));
        require(success, string(abi.encodePacked("HB Utils: fail static call ", sig)));

        if (isString) {
            if (data.length == 32) {
                data = abi.encodePacked(data);
            }
            require(data.length > 0, string(abi.encodePacked("HB Utils: Empty ", sig)));
        } else  {
            require(data.length == 32, "HB Utils: not uint<M>");
        }

        return data;
    }

    function callTokenURI(address token, uint256[] memory tokenIds) internal view returns(string[] memory) {
        string[] memory URIs = new string[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            (bool success, bytes memory data) = token.staticcall(
                abi.encodeWithSignature("tokenURI(uint256)", tokenIds[i])
            );
            require(success, "HB Utils: fail TokenURI");
            URIs[i] = abi.decode(data, (string));
        }
        return URIs;
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(bytes(a)) == keccak256(bytes(b));
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IHERC721 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns(string memory);
    function balanceOf(address account) external view returns (uint256);
    function tokenStandard() external view returns (uint256);

    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeMint(address to, uint256 tokenId, string memory uri) external;

    function burnFrom(uint256 tokenId) external;
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IHERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function tokenStandard() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external;
    function transferFrom(address from, address to, uint256 amount) external returns(bool);
    function mint(address to, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "./IHERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeHERC20 {
    using Address for address;

    function safeTransfer(
        IHERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IHERC20 token,
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
        IHERC20 token,
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
        IHERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IHERC20 token,
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
    function _callOptionalReturn(IHERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
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

import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

interface IHamsterLock {
    function owner() external view returns(address);
    function isHamsterLock() external view returns(bool);
    function isHamsterBridge() external view returns(bool);
    function isLocked() external view returns(bool);
    function blacklist(address) external view returns(bool);
}

abstract contract HamsterLock is Pausable {

    event Locked(address account);
    event Unlocked(address account);

    bool internal _isHB;
    bool internal _locked;
    address public owner;
    address internal _proposedOwner;

    mapping(address => bool) public operators;

    event SetOperator(address indexed operator, bool state);
    event NewOwner(address indexed newOwner);

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    receive() external payable {revert("HamsterLock: revert ether");}
    fallback() external {revert(string(abi.encodePacked("HamsterLock: unassigned ", toAsciiString(msg.sender), "-", toAsciiString(address(this)))));}

    modifier onlyOwner() {
        require(msg.sender == owner, "HamsterLock: Not owner");
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender], "HamsterLock: Unauthorized account");
        _;
    }

    modifier whenUnlocked() {
        require(!this.isLocked(), "HamsterLock: In lockdown");
        _;
    }

    function isHamsterLock() public pure virtual returns(bool) {
        return true;
    }

    function isHamsterBridge() public view virtual returns(bool) {
        return _isHB;
    }

    function isLocked() external view virtual returns(bool) {
        return _locked;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function lock(bool state) external onlyOwner {
        _lock(state);
        if (state) {
            emit Locked(msg.sender);
        } else {
            emit Unlocked(msg.sender);
        }
    }

    function _lock(bool _state) private {
        _locked = _state;
    }

    function setOperator(address operator, bool state) external onlyOwner () {
        if (operators[operator] != state) {
            operators[operator] = state;
            emit SetOperator(operator, state);
        }
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "HamsterLock: new owner is zero address");
        _proposedOwner = newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == _proposedOwner, "HamsterLock: Not proposed owner");
        owner = msg.sender;
        _proposedOwner = address(0);
        emit NewOwner(msg.sender);
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