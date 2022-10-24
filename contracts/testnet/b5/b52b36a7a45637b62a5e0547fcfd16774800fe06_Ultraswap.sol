// SPDX-License-Identifier: CC-BY-ND-4.0

pragma solidity ^0.8.17;

import "./interfaces.sol";
import "./uniswap.sol";

// SECTION Structures
// NOTE Ultraswap specific structures
contract structures {

    struct NFT {
        string name;
        string symbol;
        uint[] token_ids;
        mapping(uint => address) token_id_to_owner;
        mapping(address => uint[]) owner_to_token_ids;
    }

    struct TOKEN {
        string name;
        string symbol;
        uint decimals;
    }

    mapping (bytes32 => TOKEN) public tokens;
    mapping (address => bytes32) public tokens_by_address;

    struct PAIR {
        address token;
        address pairing;
        uint amount_token;
        uint amount_pairing;
        uint tokens_accrued;
        uint pairing_accrued;
        mapping(address => uint) lp_owners;
    }

    mapping (bytes32 => PAIR) public pairs;

}
// !SECTION Structures

// SECTION Swap methods
// NOTE Swap methods that will be used in the UltraSwap contract
contract swap_methods is protected, structures {

    // SECTION Pool view
    function current_pool(bytes32 liquidity) 
                            public view returns(uint _tokens, uint _paired) {
            // REVIEW Division by 0?
            uint paired_total = (pairs[liquidity].amount_pairing + 
                                        pairs[liquidity].pairing_accrued);
                
            uint tokens_total = (pairs[liquidity].tokens_accrued + 
                                        pairs[liquidity].amount_token);

            return(tokens_total, paired_total);
    }

    function current_pool_addresses(bytes32 liquidity) 
                            public view returns(address _token, address _pairing) {
            return(pairs[liquidity].token, pairs[liquidity].pairing);
    }

    // !SECTION Pool view

    // SECTION Swap and relative calculations

    // SECTION Swap simulations

    /// @dev Returns the result of a token sell after all the possible checks
    function simulate_swap_token_for_pairing(bytes32 liquidity,
                                             uint token_amount,
                                             uint min_pairing_out) 
                                             public view returns(uint out_value_) {
        // REVIEW Safety and specific cases
        (uint token_liquidity, uint pairing_liquidity) = current_pool(liquidity);
        uint out_value = get_amount_out(token_amount,
                                        token_liquidity,
                                        pairing_liquidity);
        require(out_value >= min_pairing_out, "ULTRASWAP: Insufficient output");   
        return out_value; 
    }

    /// @dev Returns the result of a token buy after all the possible checks
    function simulate_swap_pairing_for_token(bytes32 liquidity,
                                             uint pairing_amount,
                                             uint min_token_out) 
                                             public view returns(uint out_value_) {
        // REVIEW Safety and specific cases
        (uint token_liquidity, uint pairing_liquidity) = current_pool(liquidity);
        uint out_value = get_amount_out(pairing_amount,
                                        pairing_liquidity,
                                        token_liquidity);
        require(out_value >= min_token_out, "ULTRASWAP: Insufficient output");   
        return out_value; 
    }
    // !SECTION Swap simulations

    // SECTION Swap actuations

    // ANCHOR Swap events
    event swapped_tkn_for_pair(bytes32 liquidity, uint token_amount, uint pair_out, uint actual_price);
    event swapped_pair_for_tkn(bytes32 liquidity, uint pair_amount, uint tkn_out, uint actual_price);

    /// @dev Executes a token sell using simulation and actuation
    // @notice Requires approval already settled
    function swap_token_for_pairing(bytes32 liquidity,
                                    uint token_amount,
                                    uint min_pairing_out) public safe 
                                    returns (uint _out_) {
        uint out = simulate_swap_token_for_pairing
                   (liquidity, token_amount, min_pairing_out);
        // REVIEW Safety and specific cases
        require(pairs[liquidity].pairing_accrued + 
                pairs[liquidity].amount_pairing 
                >= out, "Not enough liquidity");
        // Injecting new tokens in liquidity
        pairs[liquidity].tokens_accrued += token_amount;
        // Taking out pairing value (first from accrued) in liquidity
        uint pairing_accrued = pairs[liquidity].pairing_accrued;
        if(pairing_accrued >= out) {
            pairs[liquidity].pairing_accrued -= out;
        } else {
            uint difference = out - pairs[liquidity].pairing_accrued;
            pairs[liquidity].pairing_accrued = 0;
            pairs[liquidity].amount_pairing -= difference;
        }

        // Take the tokens, give the pairing
        IERC20 token = IERC20(pairs[liquidity].token);
        require(token.balanceOf(msg.sender) >= token_amount, "Not enough tokens");
        IERC20 paired = IERC20(pairs[liquidity].pairing);
        require(paired.balanceOf(address(this)) >= out, "Not enough pairing funds");
        bool success = token.transferFrom(msg.sender, address(this), token_amount);
        require(success, "Cannot transfer tokens: allowance?");
        // NOTE Adjusting tokens stored 
        pairs[liquidity].amount_token += token_amount;
        bool paid = paired.transfer(msg.sender, out);
        require(paid, "Cannot pay seller");
        // Returns
        // REVIEW Event emission
        emit swapped_tkn_for_pair(liquidity, token_amount, out, out / token_amount);
        return(out);
    }

    /// @dev Executes a token buy using simulation and actuation
    // @notice Requires approval already settled
    function swap_pairing_for_token(bytes32 liquidity,
                                    uint pairing_amount,
                                    uint min_token_out) public safe 
                                    returns (uint _out_) {
        uint out = simulate_swap_pairing_for_token
                   (liquidity, pairing_amount, min_token_out);
        
        // REVIEW Safety and specific cases
        require(pairs[liquidity].tokens_accrued + 
                pairs[liquidity].amount_token
                >= out, "Not enough liquidity");
        // Injecting new pairing in liquidity
        pairs[liquidity].pairing_accrued += pairing_amount;
        // Taking out token value (first from accrued) in liquidity
        uint tokens_accrued = pairs[liquidity].tokens_accrued;
        if(tokens_accrued >= out) {
            pairs[liquidity].tokens_accrued -= out;
        } else {
            uint difference = out - pairs[liquidity].tokens_accrued;
            pairs[liquidity].tokens_accrued = 0;
            pairs[liquidity].amount_token -= difference;
        }
        // Take the liquidity, give the tokens
        IERC20 token = IERC20(pairs[liquidity].token);
        IERC20 paired = IERC20(pairs[liquidity].pairing);
        require(paired.balanceOf(msg.sender) >= pairing_amount, "Not enough pairings");
        require(token.balanceOf(address(this)) >= out, "Not enough token funds");
        bool success = paired.transferFrom(msg.sender, address(this), pairing_amount);
        require(success, "Cannot transfer pairing: allowance?");
        bool sold = token.transfer(msg.sender, out);
        // NOTE Adjusting tokens stored 
        pairs[liquidity].amount_token -= out;
        require(sold, "Cannot give tokens to seller");
        // Returns
        // REVIEW Event emission
        emit swapped_pair_for_tkn(liquidity, pairing_amount, out, out / pairing_amount);
        return(out);
    }
    // !SECTION Swap actuations

    // SECTION Amount out calculator
    /// @dev Calculate the output amount given a swap
    // @param to_deposit Quantity of Token_1 to deposit in pair
    // @param to_deposit_liq Liquidity of Token_1
    // @param to_withdraw_liq Liquidity of Token_2
    function get_amount_out(
        uint256 deposit_amount,
        uint256 deposit_token_liquidity,
        uint256 withdraw_token_liquidity
    ) private pure returns (uint256 out_qty) {
        require(deposit_amount > 0, "ULTRASWAP: INSUFFICIENT_INPUT_AMOUNT");
        require(
            deposit_token_liquidity > 0 && withdraw_token_liquidity > 0,
            "ULTRASWAP: INSUFFICIENT_LIQUIDITY"
        );
        uint256 to_deposit_with_precision = deposit_amount * (1000);
        uint256 numerator = to_deposit_with_precision * (withdraw_token_liquidity);
        uint256 denominator = deposit_token_liquidity * (1000) + (to_deposit_with_precision);
        out_qty = numerator / denominator;
        return out_qty;
    }
    // !SECTION Amount out calculator

    // !SECTION Swap and relative calculations

}
// !SECTION Swap methods


// SECTION Ultraswap Contract
contract Ultraswap is swap_methods, ModernTypes {

    // NOTE Derived from interfaces.sol
    using bitwise_boolean for uint;

    // NOTE Abovementioned library 'structures' is used as a namespace

    // SECTION Variables

    // NOTE Uniswap variables
    address uniswap_factory_address;
    address uniswap_router_address;
    IUniswapV2Factory uniswap_factory;
    IUniswapV2Router02 uniswap_router;

    // NOTE Ultraswap contract status flags
    uint status;

    // !SECTION Variables

    constructor() {
        // Giving ownership to the deployer
        owner = msg.sender;
        is_auth[msg.sender] = true;
        // Setting up the uniswap compatibility layer (on bsc testnet)
        uniswap_factory_address = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        uniswap_factory = IUniswapV2Factory(uniswap_factory_address);
        uniswap_router_address = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc; //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        uniswap_router = IUniswapV2Router02(uniswap_router_address);
    }

}
// !SECTION Ultraswap Contract