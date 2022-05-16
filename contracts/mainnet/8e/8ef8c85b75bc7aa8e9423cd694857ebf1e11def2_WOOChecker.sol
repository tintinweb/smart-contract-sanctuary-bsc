/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// File: contracts/SmartRoute/intf/IWooPP.sol

pragma solidity 0.6.9;


interface IWooPP {
    /// @dev Swap baseToken into quoteToken
    /// @param baseToken the base token
    /// @param baseAmount amount of baseToken that user want to swap
    /// @param minQuoteAmount minimum amount of quoteToken that user accept to receive
    /// @param to quoteToken receiver address
    /// @param rebateTo the wallet address for rebate
    /// @return quoteAmount the swapped amount of quote token
    function sellBase(
        address baseToken,
        uint256 baseAmount,
        uint256 minQuoteAmount,
        address to,
        address rebateTo
    ) external returns (uint256 quoteAmount);

    /// @dev Swap quoteToken into baseToken
    /// @param baseToken the base token
    /// @param quoteAmount amount of quoteToken that user want to swap
    /// @param minBaseAmount minimum amount of baseToken that user accept to receive
    /// @param to baseToken receiver address
    /// @param rebateTo the wallet address for rebate
    /// @return baseAmount the swapped amount of base token
    function sellQuote(
        address baseToken,
        uint256 quoteAmount,
        uint256 minBaseAmount,
        address to,
        address rebateTo
    ) external returns (uint256 baseAmount);

}

// File: contracts/SmartRoute/intf/IWooracle.sol



interface IWooracle {
    /// @dev returns the state for the given base token.
    /// @param base baseToken address
    /// @return priceNow the current price of base token
    /// @return spreadNow the current spread of base token
    /// @return coeffNow the slippage coefficient of base token
    /// @return feasible whether the current state is feasible and valid
    function state(address base)
        external
        view
        returns (
            uint256 priceNow,
            uint256 spreadNow,
            uint256 coeffNow,
            bool feasible
        );
}

// File: contracts/SmartRoute/intf/IWooGuardian.sol


interface IWooGuardian {
    function checkSwapPrice(
        uint256 price,
        address fromToken,
        address toToken
    ) external view;

    function checkInputAmount(address token, uint256 inputAmount) external view;

    function checkSwapAmount(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount
    ) external view;
}

// File: contracts/lib/InitializableOwnable.sol


/**
 * @title Ownable
 * @author DODO Breeder
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable {
    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier notInitialized() {
        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }

    // ============ Functions ============

    function initOwner(address newOwner) public notInitialized {
        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {
        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

// File: contracts/SmartRoute/sampler/wooChecker.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/






contract WOOChecker is InitializableOwnable{
    address QUOTE_TOKEN;
    address WOO_ORACLE;
    address WOO_GUARDIAN;

    constructor(
        address _quoteToken,
        address _wooracle,
        address _wooGuardian
    ) public {
        QUOTE_TOKEN = _quoteToken;
        WOO_ORACLE = _wooracle;
        WOO_GUARDIAN = _wooGuardian;
    }

    function init(address owner) external {
        initOwner(owner);
    }
    
    function checkTokenPrice(
        address baseToken
    ) public view returns (bool) {
        bool flag = true;

        uint256 p;
        bool isFeasible;
        (p, , ,isFeasible) = IWooracle(WOO_ORACLE).state(baseToken);

        if(isFeasible == false) flag = false;
        else{
            try IWooGuardian(WOO_GUARDIAN).checkSwapPrice(p, baseToken, QUOTE_TOKEN) {
                flag;
            } catch {
                flag = false;
            }
        }

        return flag;
    }

    function setWooracle(address new_wooracle) public onlyOwner {
        WOO_ORACLE = new_wooracle;
    }

    function setWooGuardian(address new_guardian) public onlyOwner {
        WOO_GUARDIAN = new_guardian;
    }

    function setQuoteToken(address new_quoteToken) public onlyOwner {
        QUOTE_TOKEN = new_quoteToken;
    }
}