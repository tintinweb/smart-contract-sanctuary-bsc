/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.0;



/* -------------------------------------------------------------------------- */
/*                                   IMPORTS                                  */
/* -------------------------------------------------------------------------- */

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*///////////////////////////////////////////////////////////////
                             EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*///////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*///////////////////////////////////////////////////////////////
                              EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*///////////////////////////////////////////////////////////////
                       INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Gnosis (https://github.com/gnosis/gp-v2-contracts/blob/main/src/contracts/libraries/GPv2SafeERC20.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
library SafeTransferLib {
    /*///////////////////////////////////////////////////////////////
                            ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                           ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 100 because the calldata length is 4 + 32 * 3.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function didLastOptionalReturnCallSucceed(bool callStatus) private pure returns (bool success) {
        assembly {
            // Get how many bytes the call returned.
            let returnDataSize := returndatasize()

            // If the call reverted:
            if iszero(callStatus) {
                // Copy the revert message into memory.
                returndatacopy(0, 0, returnDataSize)

                // Revert with the same message.
                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // Set success to whether it returned true.
                success := iszero(iszero(mload(0)))
            }
            case 0 {
                // There was no return data.
                success := 1
            }
            default {
                // It returned some malformed input.
                success := 0
            }
        }
    }
}

/// @notice Lucky7 A Token
contract a777 is ERC20("Lucky7s Alpha Token (a777)", "a777", 18) {

    /* ---------------------------------------------------------------------- */
    /*                                DEPENDENCIES                            */
    /* ---------------------------------------------------------------------- */

    using SafeTransferLib for ERC20;

    /* ---------------------------------------------------------------------- */
    /*                             IMMUTABLE STATE                            */
    /* ---------------------------------------------------------------------- */

    /// @notice BUSD tokenIn address
    ERC20 public immutable BUSD = ERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);

    /// @notice Error related to amount
    string constant AMOUNT_ERROR = "!AMOUNT";

    /// @notice Error related to token address
    string constant TOKEN_IN_ERROR = "!TOKEN_IN";

    /// @notice Error minting exceeds supply
    string constant EXCEEDS_SUPPLY = "EXCEEDS_SUPPLY";

    /// @notice Error transfers paused
    string constant PAUSED = "PAUSED";

    /* ---------------------------------------------------------------------- */
    /*                              MUTABLE STATE                             */
    /* ---------------------------------------------------------------------- */

    /// @notice Address that is recipient of raised funds + access control
    address public treasury = 0x6be04f7ba742C5ae3DB9dd7774191bbEFa208ec2;

    /// @notice Returns the current a777 price in DAI/FRAX
    uint256 public rate = 75;

    uint256 public numWhitelisted;

    /// @notice Returns the max supply of a777 that is allowed to be minted (in total)
    uint256 public maxSupply = 700000000 * 1e18;

    uint256 public maxAmount = 2000000 * 1e18;

    /// @notice Returns the total amount of a777 that has cumulatively been minted
    uint256 public totalMinted;

    /// @notice Returns whether transfers are paused
    bool public transfersPaused = true;

    /* ---------------------------------------------------------------------- */
    /*                              STRUCTURED STATE                          */
    /* ---------------------------------------------------------------------- */

    /// @notice Structure of Participant vesting storage
    struct Participant {
        uint256 purchased; // amount (in total) of a777 that user has purchased
        uint256 redeemed;  // amount (in total) of a777 that user has redeemed
    }

    /// @notice             maps an account to vesting storage
    /// address             - account to check
    /// returns Participant - Structured vesting storage
    mapping(address => Participant) public participants;


    mapping(address => bool) public whitelisted;

    /* ---------------------------------------------------------------------- */
    /*                                  EVENTS                                */
    /* ---------------------------------------------------------------------- */

    /// @notice Emitted when treasury changes treasury address
    /// @param  treasury address of new treasury
    event TreasurySet(address treasury);

    /// @notice             Emitted when a new round is set by treasury
    /// @param  rate        new price of a777 in DAI/FRAX
    event NewRound(uint256 rate);

    /// @notice             Emitted when maxSupply of a777 is burned or minted to target
    /// @param  target      target to which to mint a777 or burn if target = address(0)
    /// @param  amount      amount of a777 minted to target or burned
    /// @param  totalMinted amount of a777 minted to target or burned
    event Managed(address target, uint256 amount, uint256 totalMinted);

    /// @notice                 Emitted when a777 minted via "mint()" or "mintWithPermit"
    /// @param  depositedFrom   address from which DAI/FRAX was deposited
    /// @param  mintedTo        address to which a777 were minted to
    /// @param  amount          amount of a777 minted
    /// @param  deposited       amount of DAI/FRAX deposited
    /// @param  totalMinted     total amount of a777 minted so far
    event Minted(
        address indexed depositedFrom,
        address indexed mintedTo,
        uint256 amount,
        uint256 deposited,
        uint256 totalMinted
    );

    /// @notice                 Emitted when Lucky7 changes max supply
    /// @param  oldMax          old max supply
    /// @param  newMax          new max supply
    event SupplyChanged(uint256 oldMax, uint256 newMax);

    /* ---------------------------------------------------------------------- */
    /*                                MODIFIERS                               */
    /* ---------------------------------------------------------------------- */

    /// @notice only allows Lucky7 treasury
    modifier onlyLucky7() {
        require(msg.sender == treasury, "!LUCKY7");
        _;
    }

    /* ---------------------------------------------------------------------- */
    /*                              ONLY LUCKY7                              */
    /* ---------------------------------------------------------------------- */

    function addWhitelist(address _address) external onlyLucky7 {
        //require(!whitelisted[_address], "already whitelisted");
        if(!whitelisted[_address])
            numWhitelisted+=1;
        whitelisted[_address] = true;
    }

    function addMultipleWhitelist(address[] calldata _addresses) external onlyLucky7 {
        require(_addresses.length <= 1000, "too many addresses");
        for (uint256 i = 0; i < _addresses.length; i++) {
            if(!whitelisted[_addresses[i]])
                numWhitelisted+=1;
            whitelisted[_addresses[i]] = true;
        }
    }

    function removeWhitelist(address _address) external onlyLucky7 {
        whitelisted[_address] = false;
    }

    /// @notice Set a new treasury address if treasury
    function setTreasury(
        address _treasury
    ) external onlyLucky7 {
        treasury = _treasury;
        emit TreasurySet(_treasury);
    }

    /// @notice             Update merkle root and rate
    /// @param _rate        price of a777 in DAI/FRAX
    function setRound(
        uint256 _rate
    ) external onlyLucky7 {
        rate = _rate;
        emit NewRound(rate);
    }

    /// @notice         mint amount to target
    /// @param target   address to which to mint; if address(0), will burn
    /// @param amount   to reduce from max supply or mint to "target"
    function manage(
        address target,
        uint256 amount
    ) external onlyLucky7 {
        uint256 newAmount = totalMinted + amount;
        require(newAmount <= maxSupply,EXCEEDS_SUPPLY);
        totalMinted = newAmount;
        // mint target amount
        _mint(target, amount);
        emit Managed(target, amount, totalMinted);
    }

    /// @notice             manage max supply
    /// @param _maxSupply   new max supply
    function manageSupply(uint256 _maxSupply) external onlyLucky7 {
        require(_maxSupply >= totalMinted, "LOWER_THAN_MINT");
        emit SupplyChanged(maxSupply, _maxSupply);
        maxSupply = _maxSupply;
    }

    /// @notice         Allows Lucky7 to pause transfers in the event of a bug
    /// @param paused   if transfers should be paused or not
    function setTransfersPaused(bool paused) external onlyLucky7 {
        transfersPaused = paused;
    }

    /* ---------------------------------------------------------------------- */
    /*                              PUBLIC LOGIC                              */
    /* ---------------------------------------------------------------------- */

    /// @notice               mint a777 by providing merkle proof and depositing DAI/FRAX
    /// @param to             whitelisted address a777 will be minted to
    /// @param tokenIn        address of tokenIn user wishes to deposit
    /// @param amountIn       amount of DAI/FRAX sender wishes to deposit for a777
    function mint(
        address to,
        address tokenIn,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        return _purchase(msg.sender, to, tokenIn, amountIn);
    }

    /// @notice         transfer "amount" of tokens from msg.sender to "to"
    /// @dev            calls "_beforeTransfer" to update vesting storage for "from" and "to"
    /// @param to       address tokens are being sent to
    /// @param amount   number of tokens being transfered
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(!transfersPaused,PAUSED);
        // default ERC20 transfer
        return super.transfer(to, amount);
    }

    /// @notice         transfer "amount" of tokens from "from" to "to"
    /// @dev            calls "_beforeTransfer" to update vesting storage for "from" and "to"
    /// @param from     address tokens are being transfered from
    /// @param to       address tokens are being sent to
    /// @param amount   number of tokens being transfered
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(!transfersPaused,PAUSED);
        // default ERC20 transfer
        return super.transferFrom(from, to, amount);
    }

    /* ---------------------------------------------------------------------- */
    /*                             INTERNAL LOGIC                             */
    /* ---------------------------------------------------------------------- */

    /// @notice               Deposits FRAX/DAI for a777 if merkle proof exists in specified round
    /// @param sender         address sending transaction
    /// @param to             whitelisted address purchased a777 will be sent to
    /// @param tokenIn        address of tokenIn user wishes to deposit
    /// @param amountIn       amount of BUSD sender wishes to deposit for a777
    function _purchase(
        address sender,
        address to,
        address tokenIn,
        uint256 amountIn
    ) internal returns(uint256 amountOut) {
        // Make sure payment tokenIn is either DAI or FRAX
        require(tokenIn == address(BUSD), TOKEN_IN_ERROR);

        require(whitelisted[to] == true, 'to is not whitelisted');

        // Calculate rate of a777 that should be returned for "amountIn"
        amountOut = amountIn * 1e23 / rate;

        // make sure total minted + amount is less than or equal to maximum supply
        require(totalMinted + amountOut <= maxSupply, EXCEEDS_SUPPLY);

        // Interface storage for participant
        Participant storage participant = participants[to];

        // Increase participant.purchased to account for newly purchased tokens
        participant.purchased += amountOut;

        // Purchased above max purchasable amount
        require(participant.purchased <= maxAmount, AMOUNT_ERROR);

        // Increase totalMinted to account for newly minted supply
        totalMinted += amountOut;

        // Transfer amountIn*ratio of tokenIn to treasury address
        ERC20(tokenIn).safeTransferFrom(sender, treasury, amountIn);

        // Mint tokens to address after pulling
        _mint(to, amountOut);

        emit Minted(sender, to, amountOut, amountIn, totalMinted);
    }

    /// @notice         Rescues accidentally sent tokens and ETH
    /// @param token    address of token to rescue, if address(0) rescue ETH
    function rescue(address token) external onlyLucky7 {
        if (token == address(0)) payable(treasury).transfer( address(this).balance );
        else ERC20(token).transfer(treasury, ERC20(token).balanceOf(address(this)));
    }
}