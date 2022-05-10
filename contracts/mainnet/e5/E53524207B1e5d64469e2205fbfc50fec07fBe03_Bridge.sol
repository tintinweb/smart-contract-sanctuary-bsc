// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IEmpireToken.sol";

contract Bridge {
    address public validator;
    uint256 public fee = 2000;
    uint256 public feeDominator = 10000;
    uint256 private currentNonce = 0;
    address payable public feeRecevier;
    mapping(bytes32 => bool) public processedSwap;
    mapping(bytes32 => bool) public processedRedeem;
    mapping(string => address) public tickerToToken;
    mapping(uint256 => bool) public activeChainIds;

    event SwapInitialized(address indexed from, address indexed to, uint256 amount, string ticker, uint256 chainTo, uint256 chainFrom, uint256 nonce);

    event Redeemed(address indexed from, address indexed to, uint256 amount, string ticker, uint256 chainTo, uint256 chainFrom, uint256 nonce);
    event WithdrawalFee(address indexed account, uint256 amount);

    constructor(address payable _feeRecevier) {
        validator = msg.sender;
        feeRecevier = _feeRecevier;
    }

    function swap(
        address to,
        uint256 amount,
        string memory ticker,
        uint256 chainTo,
        uint256 chainFrom
    ) external payable {
        uint256 _fee = calculateFee();
        require(msg.value >= _fee, "Swap fee is not fulfilled");
        uint256 nonce = currentNonce;
        currentNonce++;

        require(processedSwap[keccak256(abi.encodePacked(msg.sender, to, amount, chainFrom, chainTo, ticker, nonce))] == false, "swap already processed");
        bytes32 hash_ = keccak256(abi.encodePacked(msg.sender, to, amount, chainFrom, chainTo, ticker, nonce));

        processedSwap[hash_] = true;
        address token = tickerToToken[ticker];
        IEmpireToken(token).burn(msg.sender, amount);
        emit SwapInitialized(msg.sender, to, amount, ticker, chainTo, chainFrom, nonce);
    }

    function redeem(
        address from,
        address to,
        uint256 amount,
        string memory ticker,
        uint256 chainFrom,
        uint256 chainTo,
        uint256 nonce,
        bytes calldata signature
    ) external {
        bytes32 hash_ = keccak256(abi.encodePacked(from, to, amount, ticker, chainFrom, chainTo, nonce));
        require(processedRedeem[hash_] == false, "Redeem already processed");
        processedRedeem[hash_] = true;

        require(getChainID() == chainTo, "invalid chainTo");
        require(recoverSigner(hashMessage(hash_), signature) == validator, "invalid sig");

        address token = tickerToToken[ticker];
        IEmpireToken(token).mint(to, amount);

        emit Redeemed(from, to, amount, ticker, chainTo, chainFrom, nonce);
    }

    /**
     * @dev Recover signer address from a message by using their signature
     * @param message bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param sig bytes signature, the signature is generated using web3.eth.sign()
     */
    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function hashMessage(bytes32 message) private pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, message));
    }

    function isValidator() internal view returns (bool) {
        return (validator == msg.sender);
    }

    modifier onlyValidator() {
        require(isValidator(), "DENIED : Not Validator");
        _;
    }

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function updateChainById(uint256 chainId, bool isActive) external onlyValidator {
        activeChainIds[chainId] = isActive;
    }

    function includeToken(string memory ticker, address addr) external onlyValidator {
        tickerToToken[ticker] = addr;
    }

    function excludeToken(string memory ticker) external onlyValidator {
        delete tickerToToken[ticker];
    }

    function updateValidator(address _validator) external onlyValidator {
        validator = _validator;
    }

    function updateFeeRecevier(address payable _feeRecevier) external onlyValidator {
        feeRecevier = _feeRecevier;
    }

    function updateFee(uint256 _fee) external onlyValidator {
        fee = _fee;
    }

    function calculateFee() public view returns (uint256) {
        return (fee * (1e18)) / feeDominator;
    }

    function withdrawFee() external onlyValidator {
        uint256 amount = (address(this)).balance;
        feeRecevier.transfer(amount);
        emit WithdrawalFee(feeRecevier, amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IEmpireToken {
    function mint(address account, uint256 tAmount) external;

    function burn(address account, uint256 tAmount) external;
}