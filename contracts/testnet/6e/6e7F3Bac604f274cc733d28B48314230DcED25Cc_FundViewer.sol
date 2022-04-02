//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../interfaces/IFactory.sol";
import "../interfaces/IFund.sol";
import "../interfaces/IShop.sol";
import "../interfaces/IToken.sol";

contract FundViewer {
    struct FundInfo {
        address fund;
        string fundName;
        string fundSymbol;
        address token;
        uint256 count;
        uint256 totalValue;
        address owner;
    }

    function getFund(address _fund) public view returns (FundInfo memory) {
        
        address _token = IFund(_fund).GetToken();

        return
            FundInfo({
                fund: _fund,
                fundName: IToken(_token).name(),
                fundSymbol: IToken(_token).symbol(),
                token: IFund(_fund).GetToken(),
                count: IFund(_fund).GetSourcesCount(),
                totalValue: IFund(_fund).GetTotalValue(),
                owner: IFund(_fund).GetOwner()
            });
    }

    function getFunds(address _factory)
        public
        view
        returns (FundInfo[] memory)
    {
        address[] memory _fundsRaw = IFactory(_factory).getFunds();

        FundInfo[] memory _funds = new FundInfo[](_fundsRaw.length);

        if (_fundsRaw.length == 0) {
            return new FundInfo[](0);
        } else {
            for (uint256 i = 0; i < _fundsRaw.length; i++) {
                _funds[i] = getFund(_fundsRaw[i]);
            }

            return _funds;
        }
    }

    function userFunds(address _user, address _factory)
        external
        view
        returns (FundInfo[] memory)
    {
        FundInfo[] memory _funds = getFunds(_factory);

        if (_funds.length == 0) {
            return new FundInfo[](0);
        } else {
            FundInfo[] memory _userFunds = new FundInfo[](_funds.length);

            for (uint256 i = 0; i < _funds.length; i++) {
                if (IERC20Metadata(_funds[i].token).balanceOf(_user) > 0) {
                    _userFunds[i] = _funds[i];
                }
            }

            return _userFunds;
        }
    }

    function balances(address[] memory users, address[] memory tokens)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory addrBalances = new uint256[](
            tokens.length * users.length
        );

        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 addrIdx = j + tokens.length * i;

                if (tokens[j] != address(0x0)) {
                    addrBalances[addrIdx] = IERC20Metadata(tokens[j]).balanceOf(
                        users[i]
                    );
                } else {
                    addrBalances[addrIdx] = users[i].balance;
                }
            }
        }

        return addrBalances;
    }

    struct FundConfiguration {
        address[] sources;
        uint256 count;
        uint256[] weight;
        uint256[] holdings;
        uint256[] held;
        uint256 total;
        uint256 monthlyCost;
        address owner;
    }

    function getFundConfiguration(address _factory, address _fund)
        external
        view
        returns (FundConfiguration memory)
    {
        address _token = IFund(_fund).GetToken();
        uint256 _count = IFund(_fund).GetSourcesCount();

        FundConfiguration memory fundconfiguration;

        for (uint256 i = 0; i < _count; i++) {
            address _a = IFund(_fund).GetSource(i);
            uint256 _h = IFund(_fund).GetHeldValue(_a);
            uint256 _w = IFund(_fund).GetWeights(_a);
            uint256 _hh = IFund(_fund).GetHoldings(_a);
            fundconfiguration.sources[i] = _a;
            fundconfiguration.held[i] = _h;
            fundconfiguration.weight[i] = _w;
            fundconfiguration.holdings[i] = _hh;
        }

        fundconfiguration.count = _count;
        fundconfiguration.total = IFund(_fund).GetTotalValue();
        fundconfiguration.owner = IFund(_fund).GetOwner();
        fundconfiguration.monthlyCost = IFactory(_factory).monthlyCost();

        return fundconfiguration;
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IFactory{
    function getFunds() external view returns (address[] memory);
    function shop() external view returns (address);
    function monthlyCost() external view returns (uint256);
    function subscriptions(address _fund) external view returns (uint256);
    function containsFund(address _fund) external view returns (bool);
    function GetFee() external returns (uint);
    function GetTreasury() external  returns (address);
    function GetRouter() external  returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IFund{
    function GetTotalValue() external view returns (uint256);
    function GetHoldings(address token_contract) external view returns(uint256);
    function GetWeights(address token_contract) external view returns(uint256);
    function GetHeldValue(address token_contract) external view returns(uint256);
    function GetAccountValue(address owner) external view returns(uint256);
    function GetAggregator(address token_contract) external view returns(address);
    function GetSourcesCount() external view returns(uint);
    function GetSource(uint index) external view returns(address);
    function GetToken() external view returns(address);
    function SetToken(address token) external view returns(bool);
    function GetOwner() external view returns(address);
    function SetOwner(address account) external;
    function Withdraw(uint256 tokenAmount) external;
    function Deposit(uint256 _amount) external;
}

pragma solidity ^0.8.6;

interface IShop {
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IToken {
    function burn(address account, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function mintTo(address account, uint256 amount) external;


    
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

   function name() external view returns (string memory);

    function symbol() external view returns (string memory);
    
    function setFundAddress(address account) external ; 
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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