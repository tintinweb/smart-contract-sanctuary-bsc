pragma solidity ^0.8.6;
/*
 * SPDX-License-Identifier: MIT
 */
pragma experimental ABIEncoderV2;

// import "hardhat/console.sol";
import "./Owner.sol";
import {TeleportTokenFactory} from "./TeleportTokenFactory.sol";

contract Verify {
    function recoverSigner(bytes32 message, bytes memory sig)
        public
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(message, v, r, s);
        }
    }

    function splitSignature(bytes memory sig)
        public
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
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) v += 27;

        return (v, r, s);
    }
}

library Endian {
    /* https://ethereum.stackexchange.com/questions/83626/how-to-reverse-byte-order-in-uint256-or-bytes32 */
    function reverse64(uint64 input) internal pure returns (uint64 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00FF00FF00) >> 8) | ((v & 0x00FF00FF00FF00FF) << 8);

        // swap 2-byte long pairs
        v = ((v & 0xFFFF0000FFFF0000) >> 16) | ((v & 0x0000FFFF0000FFFF) << 16);

        // swap 4-byte long pairs
        v = (v >> 32) | (v << 32);
    }

    function reverse32(uint32 input) internal pure returns (uint32 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00) >> 8) | ((v & 0x00FF00FF) << 8);

        // swap 2-byte long pairs
        v = (v >> 16) | (v << 16);
    }

    function reverse16(uint16 input) internal pure returns (uint16 v) {
        v = input;

        // swap bytes
        v = (v >> 8) | (v << 8);
    }
}

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
abstract contract ERC20Interface {
    function totalSupply() public view virtual returns (uint256);

    function balanceOf(address tokenOwner)
        public
        view
        virtual
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        public
        view
        virtual
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens)
        public
        virtual
        returns (bool success);

    function approve(address spender, uint256 tokens)
        public
        virtual
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
abstract contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes memory data
    ) public virtual;
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply, added teleport method
// ----------------------------------------------------------------------------
contract TeleportToken is ERC20Interface, Owned, Verify {
    TeleportTokenFactory factory;

    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;
    uint8 public threshold;
    uint8 public thisChainId;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    mapping(uint64 => mapping(address => bool)) signed;
    mapping(uint64 => bool) public claimed;

    event Teleport(
        address indexed from,
        string to,
        uint256 tokens,
        uint256 chainId
    );
    event Claimed(
        uint64 id,
        address toAddress,
        address tokenAddress,
        uint256 amount
    );

    struct TeleportData {
        uint64 id;
        uint32 ts;
        uint64 fromAddr;
        uint256 quantity;
        uint64 symbolRaw;
        uint8 chainId;
        address toAddress;
        address tokenAddress;
        uint8 nativeDecimals;
    }

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(
        string memory _symbol,
        string memory _name,
        uint8 _decimals,
        uint256 __totalSupply,
        uint8 _threshold,
        uint8 _thisChainId
    ) {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        _totalSupply = __totalSupply * 10**uint256(_decimals);
        balances[address(0)] = _totalSupply;
        threshold = _threshold;
        thisChainId = _thisChainId;
        factory = TeleportTokenFactory(payable(address(msg.sender)));
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view override returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool success)
    {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(
        address spender,
        uint256 tokens,
        bytes memory data
    ) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(
            msg.sender,
            tokens,
            address(this),
            data
        );
        return true;
    }

    // ------------------------------------------------------------------------
    // Moves tokens to the inaccessible account and then sends event for the oracles
    // to monitor and issue on other chain
    // to : EOS address
    // tokens : number of tokens in satoshis
    // chainId : The chain id that they will be sent to
    // ------------------------------------------------------------------------

    function teleport(
        string memory to,
        uint256 tokens,
        uint256 chainid
    ) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[address(0)] = balances[address(0)].add(tokens);

        emit Transfer(msg.sender, address(0), tokens);
        emit Teleport(msg.sender, to, tokens, chainid);

        return true;
    }

    // ------------------------------------------------------------------------
    // Claim tokens sent using signatures supplied to the other chain
    // ------------------------------------------------------------------------

    function stringToBytes32(string memory source)
        public
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function verifySigData(bytes memory sigData)
        private
        returns (TeleportData memory)
    {
        TeleportData memory td;

        uint64 id;
        uint32 ts;
        uint64 fromAddr;
        uint64 quantity;
        uint64 symbolRaw;
        uint8 chainId;
        address toAddress;
        address tokenAddress;
        uint8 nativeDecimals;
        // uint64 requiredSymbolRaw;

        assembly {
            id := mload(add(add(sigData, 0x8), 0))
            ts := mload(add(add(sigData, 0x4), 8))
            fromAddr := mload(add(add(sigData, 0x8), 12))
            quantity := mload(add(add(sigData, 0x8), 20))
            symbolRaw := mload(add(add(sigData, 0x8), 29))
            chainId := mload(add(add(sigData, 0x1), 36))
            toAddress := mload(add(add(sigData, 0x14), 37))
            tokenAddress := mload(add(add(sigData, 0x14), 70))
            nativeDecimals := mload(add(add(sigData, 0x1), 90))
        }
        td.id = Endian.reverse64(id);
        td.ts = Endian.reverse32(ts);
        td.fromAddr = Endian.reverse64(fromAddr);
        td.symbolRaw = Endian.reverse64(symbolRaw);
        td.chainId = chainId;
        td.toAddress = toAddress;
        td.tokenAddress = tokenAddress;
        td.nativeDecimals = nativeDecimals;
        td.quantity =
            Endian.reverse64(quantity) *
            10**(decimals - nativeDecimals);

        // requiredSymbolRaw = uint64(
        //     bytes8(stringToBytes32(TeleportToken.symbol))
        // );
        // require(requiredSymbolRaw == symbolRaw - td.chainId, "Wrong symbol");
        require(address(this) == td.tokenAddress, "Invalid token address");
        require(thisChainId == td.chainId, "Invalid Chain ID");
        require(
            block.timestamp < SafeMath.add(td.ts, (60 * 60 * 24 * 30)),
            "Teleport has expired"
        );
        require(!claimed[td.id], "Already Claimed");

        claimed[td.id] = true;

        return td;
    }

    function claim(bytes memory sigData, bytes[] calldata signatures)
        public
        returns (address toAddress)
    {
        TeleportData memory td = verifySigData(sigData);

        // verify signatures
        require(sigData.length == 91, "Signature data is the wrong size");
        require(
            signatures.length <= 10,
            "Maximum of 10 signatures can be provided"
        );

        bytes32 message = keccak256(sigData);

        uint8 numberSigs = 0;

        for (uint8 i = 0; i < signatures.length; i++) {
            address potential = Verify.recoverSigner(message, signatures[i]);

            // console.log(potential);
            // console.log(oracles[potential]);
            // Check that they are an oracle and they haven't signed twice
            if (factory.isOracle(potential) && !signed[td.id][potential]) {
                signed[td.id][potential] = true;
                numberSigs++;

                if (numberSigs >= threshold) {
                    break;
                }
            }
        }

        require(
            numberSigs >= threshold,
            "Not enough valid signatures provided"
        );

        balances[address(0)] = balances[address(0)].sub(td.quantity);
        balances[td.toAddress] = balances[td.toAddress].add(td.quantity);

        emit Claimed(td.id, td.toAddress, td.tokenAddress, td.quantity);
        emit Transfer(address(0), td.toAddress, td.quantity);

        return td.toAddress;
    }

    function updateThreshold(uint8 newThreshold)
        public
        onlyOwner
        returns (bool success)
    {
        if (newThreshold > 0) {
            require(newThreshold <= 10, "Threshold has maximum of 10");

            threshold = newThreshold;

            return true;
        }

        return false;
    }

    function updateChainId(uint8 newChainId)
        public
        onlyOwner
        returns (bool success)
    {
        if (newChainId > 0) {
            require(newChainId <= 100, "ChainID is too big");
            thisChainId = newChainId;

            return true;
        }

        return false;
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    receive() external payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint256 tokens)
        public
        onlyOwner
        returns (bool success)
    {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}

pragma solidity ^0.8.6;
/*
 * SPDX-License-Identifier: MIT
 */
pragma experimental ABIEncoderV2;

// import "hardhat/console.sol";
import "./Owner.sol";
import "./TeleportToken.sol";

contract Oracled is Owned {
    mapping(address => bool) public oracles;
    address[] internal oraclesArr;

    modifier onlyOracle() {
        require(
            oracles[msg.sender] == true,
            "Account is not a registered oracle"
        );

        _;
    }

    function regOracle(address _newOracle) public onlyOwner {
        require(!oracles[_newOracle], "Oracle is already registered");
        oraclesArr.push(_newOracle);
        oracles[_newOracle] = true;
    }

    function unregOracle(address _remOracle) public onlyOwner {
        require(oracles[_remOracle] == true, "Oracle is not registered");

        delete oracles[_remOracle];
    }
}

contract TeleportTokenFactory is Owned, Oracled {
    TeleportToken[] public teleporttokens;
    uint256 public creationFee = 0.01 ether;

    // Payable constructor can receive Ether
    constructor() payable {}

    function isOracle(address _address) public view returns (bool) {
        return oracles[_address];
    }

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function deposit() public payable {}

    // Call this function along with some Ether.
    // The function will throw an error since this function is not payable.
    function notPayable() public {}

    // Function to withdraw all Ether from this contract.
    function withdraw() public onlyOwner {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function create(
        string memory _symbol,
        string memory _name,
        uint8 _decimals,
        uint256 __totalSupply,
        uint8 _threshold,
        uint8 _thisChainId
    ) public payable {
        // correct fee
        require(msg.value == creationFee, "Wrong fee");
        TeleportToken tt = new TeleportToken(
            _symbol,
            _name,
            _decimals,
            __totalSupply,
            _threshold,
            _thisChainId
        );

        tt.transferOwnership(msg.sender);

        teleporttokens.push(tt);
    }

    function getTokenAddress(uint256 _index)
        public
        view
        returns (address ttAddress)
    {
        TeleportToken tt = teleporttokens[_index];

        return (address(tt));
    }

    function setFee(uint256 _fee) public onlyOwner {
        creationFee = _fee;
    }
}

pragma solidity ^0.8.6;

/*
 * SPDX-License-Identifier: MIT
 */

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}