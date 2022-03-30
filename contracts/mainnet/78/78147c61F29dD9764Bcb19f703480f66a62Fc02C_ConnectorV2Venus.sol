pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

/**
 * @title Venus.
 * @dev Lending & Borrowing.
 */

import {TokenInterface} from "../common/interfaces.sol";
import {Stores} from "../common/stores.sol";
import {Helpers} from "./helpers.sol";
import {Events} from "./events.sol";
import {VETHInterface, VTokenInterface} from "./interface.sol";

abstract contract VenusResolver is Events, Helpers {
    /**
     * @dev Deposit ETH/BEP_20Token.
     * @notice Deposit a token to Venus for lending / collaterization.
     * @param token The address of the token to deposit. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param vToken The address of the corresponding vToken.
     * @param amt The amount of the token to deposit. (For max: `uint256(-1)`)
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of tokens deposited.
     */
    function depositRaw(
        address token,
        address vToken,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        public
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _amt = getUint(getId, amt);

        require(
            token != address(0) && vToken != address(0),
            "invalid token/vToken address"
        );

        enterMarket(vToken);
        if (token == ethAddr) {
            _amt = _amt == uint256(-1) ? address(this).balance : _amt;
            VETHInterface(vToken).mint{value: _amt}();
        } else {
            TokenInterface tokenContract = TokenInterface(token);
            _amt = _amt == uint256(-1)
                ? tokenContract.balanceOf(address(this))
                : _amt;
            tokenContract.approve(vToken, _amt);
            require(VTokenInterface(vToken).mint(_amt) == 0, "deposit-failed");
        }
        setUint(setId, _amt);

        _eventName = "LogDeposit(address,address,uint256,uint256,uint256)";
        _eventParam = abi.encode(token, vToken, _amt, getId, setId);
    }

    /**
     * @dev Deposit ETH/BEP_20Token using the Mapping.
     * @notice Deposit a token to Venus for lending / collaterization.
     * @param tokenId The token id of the token to deposit.(For eg: BUSD-A)
     * @param amt The amount of the token to deposit. (For max: `uint256(-1)`)
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of tokens deposited.
     */
    function deposit(
        string calldata tokenId,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        (address token, address vToken) = venusMapping.getMapping(tokenId);
        (_eventName, _eventParam) = depositRaw(
            token,
            vToken,
            amt,
            getId,
            setId
        );
    }

    /**
     * @dev Withdraw ETH/BEP_20Token.
     * @notice Withdraw deposited token from Venus
     * @param token The address of the token to withdraw. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param vToken The address of the corresponding vToken.
     * @param amt The amount of the token to withdraw. (For max: `uint256(-1)`)
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of tokens withdrawn.
     */
    function withdrawRaw(
        address token,
        address vToken,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        public
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _amt = getUint(getId, amt);

        require(
            token != address(0) && vToken != address(0),
            "invalid token/vToken address"
        );

        VTokenInterface vTokenContract = VTokenInterface(vToken);
        if (_amt == uint256(-1)) {
            TokenInterface tokenContract = TokenInterface(token);
            uint256 initialBal = token == ethAddr
                ? address(this).balance
                : tokenContract.balanceOf(address(this));
            require(
                vTokenContract.redeem(
                    vTokenContract.balanceOf(address(this))
                ) == 0,
                "full-withdraw-failed"
            );
            uint256 finalBal = token == ethAddr
                ? address(this).balance
                : tokenContract.balanceOf(address(this));
            _amt = finalBal - initialBal;
        } else {
            require(
                vTokenContract.redeemUnderlying(_amt) == 0,
                "withdraw-failed"
            );
        }
        setUint(setId, _amt);

        _eventName = "LogWithdraw(address,address,uint256,uint256,uint256)";
        _eventParam = abi.encode(token, vToken, _amt, getId, setId);
    }

    /**
     * @dev Withdraw ETH/BEP_20Token using the Mapping.
     * @notice Withdraw deposited token from Venus
     * @param tokenId The token id of the token to withdraw.(For eg: ETH-A)
     * @param amt The amount of the token to withdraw. (For max: `uint256(-1)`)
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of tokens withdrawn.
     */
    function withdraw(
        string calldata tokenId,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        (address token, address vToken) = venusMapping.getMapping(tokenId);
        (_eventName, _eventParam) = withdrawRaw(
            token,
            vToken,
            amt,
            getId,
            setId
        );
    }

    /**
     * @dev Borrow ETH/BEP_20Token.
     * @notice Borrow a token using Venus
     * @param token The address of the token to borrow. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param vToken The address of the corresponding vToken.
     * @param amt The amount of the token to borrow.
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of tokens borrowed.
     */
    function borrowRaw(
        address token,
        address vToken,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        public
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _amt = getUint(getId, amt);

        require(
            token != address(0) && vToken != address(0),
            "invalid token/vToken address"
        );

        enterMarket(vToken);
        require(VTokenInterface(vToken).borrow(_amt) == 0, "borrow-failed");
        setUint(setId, _amt);

        _eventName = "LogBorrow(address,address,uint256,uint256,uint256)";
        _eventParam = abi.encode(token, vToken, _amt, getId, setId);
    }

    /**
     * @dev Borrow ETH/BEP_20Token using the Mapping.
     * @notice Borrow a token using Venus
     * @param tokenId The token id of the token to borrow.(For eg: DAI-A)
     * @param amt The amount of the token to borrow.
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of tokens borrowed.
     */
    function borrow(
        string calldata tokenId,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        (address token, address vToken) = venusMapping.getMapping(tokenId);
        (_eventName, _eventParam) = borrowRaw(token, vToken, amt, getId, setId);
    }

    /**
     * @dev Payback borrowed ETH/BEP_20Token.
     * @notice Payback debt owed.
     * @param token The address of the token to payback. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param vToken The address of the corresponding vToken.
     * @param amt The amount of the token to payback. (For max: `uint256(-1)`)
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of tokens paid back.
     */
    function paybackRaw(
        address token,
        address vToken,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        public
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _amt = getUint(getId, amt);

        require(
            token != address(0) && vToken != address(0),
            "invalid token/vToken address"
        );

        VTokenInterface vTokenContract = VTokenInterface(vToken);
        _amt = _amt == uint256(-1)
            ? vTokenContract.borrowBalanceCurrent(address(this))
            : _amt;

        if (token == ethAddr) {
            require(address(this).balance >= _amt, "not-enough-eth");
            VETHInterface(vToken).repayBorrow{value: _amt}();
        } else {
            TokenInterface tokenContract = TokenInterface(token);
            require(
                tokenContract.balanceOf(address(this)) >= _amt,
                "not-enough-token"
            );
            tokenContract.approve(vToken, _amt);
            require(vTokenContract.repayBorrow(_amt) == 0, "repay-failed.");
        }
        setUint(setId, _amt);

        _eventName = "LogPayback(address,address,uint256,uint256,uint256)";
        _eventParam = abi.encode(token, vToken, _amt, getId, setId);
    }

    /**
     * @dev Payback borrowed ETH/BEP_20Token using the Mapping.
     * @notice Payback debt owed.
     * @param tokenId The token id of the token to payback.(For eg: Venus-A)
     * @param amt The amount of the token to payback. (For max: `uint256(-1)`)
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of tokens paid back.
     */
    function payback(
        string calldata tokenId,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        (address token, address vToken) = venusMapping.getMapping(tokenId);
        (_eventName, _eventParam) = paybackRaw(
            token,
            vToken,
            amt,
            getId,
            setId
        );
    }

    /**
     * @dev Deposit ETH/BEP_20Token.
     * @notice Same as depositRaw. The only difference is this method stores vToken amount in set ID.
     * @param token The address of the token to deposit. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param vToken The address of the corresponding vToken.
     * @param amt The amount of the token to deposit. (For max: `uint256(-1)`)
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of vTokens received.
     */
    function depositVTokenRaw(
        address token,
        address vToken,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        public
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _amt = getUint(getId, amt);

        require(
            token != address(0) && vToken != address(0),
            "invalid token/vToken address"
        );

        enterMarket(vToken);

        VTokenInterface vTokenContract = VTokenInterface(vToken);
        uint256 initialBal = vTokenContract.balanceOf(address(this));

        if (token == ethAddr) {
            _amt = _amt == uint256(-1) ? address(this).balance : _amt;
            VETHInterface(vToken).mint{value: _amt}();
        } else {
            TokenInterface tokenContract = TokenInterface(token);
            _amt = _amt == uint256(-1)
                ? tokenContract.balanceOf(address(this))
                : _amt;
            tokenContract.approve(vToken, _amt);
            require(vTokenContract.mint(_amt) == 0, "deposit-vToken-failed.");
        }

        uint256 _cAmt;

        {
            uint256 finalBal = vTokenContract.balanceOf(address(this));
            _cAmt = sub(finalBal, initialBal);

            setUint(setId, _cAmt);
        }

        _eventName = "LogDepositVToken(address,address,uint256,uint256,uint256,uint256)";
        _eventParam = abi.encode(token, vToken, _amt, _cAmt, getId, setId);
    }

    /**
     * @dev Deposit ETH/BEP_20Token using the Mapping.
     * @notice Same as deposit. The only difference is this method stores vToken amount in set ID.
     * @param tokenId The token id of the token to depositVToken.(For eg: DAI-A)
     * @param amt The amount of the token to deposit. (For max: `uint256(-1)`)
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of vTokens received.
     */
    function depositVToken(
        string calldata tokenId,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        (address token, address vToken) = venusMapping.getMapping(tokenId);
        (_eventName, _eventParam) = depositVTokenRaw(
            token,
            vToken,
            amt,
            getId,
            setId
        );
    }

    /**
     * @dev Withdraw CETH/CBEP_20Token using vToken Amt.
     * @notice Same as withdrawRaw. The only difference is this method fetch vToken amount in get ID.
     * @param token The address of the token to withdraw. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param vToken The address of the corresponding vToken.
     * @param vTokenAmt The amount of vTokens to withdraw
     * @param getId ID to retrieve vTokenAmt
     * @param setId ID stores the amount of tokens withdrawn.
     */
    function withdrawVTokenRaw(
        address token,
        address vToken,
        uint256 vTokenAmt,
        uint256 getId,
        uint256 setId
    )
        public
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _cAmt = getUint(getId, vTokenAmt);
        require(
            token != address(0) && vToken != address(0),
            "invalid token/vToken address"
        );

        VTokenInterface vTokenContract = VTokenInterface(vToken);
        TokenInterface tokenContract = TokenInterface(token);
        _cAmt = _cAmt == uint256(-1)
            ? vTokenContract.balanceOf(address(this))
            : _cAmt;

        uint256 withdrawAmt;
        {
            uint256 initialBal = token != ethAddr
                ? tokenContract.balanceOf(address(this))
                : address(this).balance;
            require(vTokenContract.redeem(_cAmt) == 0, "redeem-failed");
            uint256 finalBal = token != ethAddr
                ? tokenContract.balanceOf(address(this))
                : address(this).balance;

            withdrawAmt = sub(finalBal, initialBal);
        }

        setUint(setId, withdrawAmt);

        _eventName = "LogWithdrawVToken(address,address,uint256,uint256,uint256,uint256)";
        _eventParam = abi.encode(
            token,
            vToken,
            withdrawAmt,
            _cAmt,
            getId,
            setId
        );
    }

    /**
     * @dev Withdraw CETH/CBEP_20Token using vToken Amt & the Mapping.
     * @notice Same as withdraw. The only difference is this method fetch vToken amount in get ID.
     * @param tokenId The token id of the token to withdraw vToken.(For eg: ETH-A)
     * @param vTokenAmt The amount of vTokens to withdraw
     * @param getId ID to retrieve vTokenAmt
     * @param setId ID stores the amount of tokens withdrawn.
     */
    function withdrawVToken(
        string calldata tokenId,
        uint256 vTokenAmt,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        (address token, address vToken) = venusMapping.getMapping(tokenId);
        (_eventName, _eventParam) = withdrawVTokenRaw(
            token,
            vToken,
            vTokenAmt,
            getId,
            setId
        );
    }

    /**
     * @dev Liquidate a position.
     * @notice Liquidate a position.
     * @param borrower Borrower's Address.
     * @param tokenToPay The address of the token to pay for liquidation.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param vTokenPay Corresponding vToken address.
     * @param tokenInReturn The address of the token to return for liquidation.
     * @param vTokenColl Corresponding vToken address.
     * @param amt The token amount to pay for liquidation.
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of paid for liquidation.
     */
    function liquidateRaw(
        address borrower,
        address tokenToPay,
        address vTokenPay,
        address tokenInReturn,
        address vTokenColl,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        public
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _amt = getUint(getId, amt);
        require(
            tokenToPay != address(0) && vTokenPay != address(0),
            "invalid token/vToken address"
        );
        require(
            tokenInReturn != address(0) && vTokenColl != address(0),
            "invalid token/vToken address"
        );

        VTokenInterface vTokenContract = VTokenInterface(vTokenPay);

        {
            (, , uint256 shortfall) = troller.getAccountLiquidity(borrower);
            require(shortfall != 0, "account-cannot-be-liquidated");
            _amt = _amt == uint256(-1)
                ? vTokenContract.borrowBalanceCurrent(borrower)
                : _amt;
        }

        if (tokenToPay == ethAddr) {
            require(address(this).balance >= _amt, "not-enough-eth");
            VETHInterface(vTokenPay).liquidateBorrow{value: _amt}(
                borrower,
                vTokenColl
            );
        } else {
            TokenInterface tokenContract = TokenInterface(tokenToPay);
            require(
                tokenContract.balanceOf(address(this)) >= _amt,
                "not-enough-token"
            );
            tokenContract.approve(vTokenPay, _amt);
            require(
                vTokenContract.liquidateBorrow(
                    borrower,
                    _amt,
                    VTokenInterface(vTokenColl)
                ) == 0,
                "liquidate-failed"
            );
        }

        setUint(setId, _amt);

        _eventName = "LogLiquidate(address,address,address,uint256,uint256,uint256)";
        _eventParam = abi.encode(
            address(this),
            tokenToPay,
            tokenInReturn,
            _amt,
            getId,
            setId
        );
    }

    /**
     * @dev Liquidate a position using the mapping.
     * @notice Liquidate a position using the mapping.
     * @param borrower Borrower's Address.
     * @param tokenIdToPay token id of the token to pay for liquidation.(For eg: ETH-A)
     * @param tokenIdInReturn token id of the token to return for liquidation.(For eg: USDC-A)
     * @param amt token amount to pay for liquidation.
     * @param getId ID to retrieve amt.
     * @param setId ID stores the amount of paid for liquidation.
     */
    function liquidate(
        address borrower,
        string calldata tokenIdToPay,
        string calldata tokenIdInReturn,
        uint256 amt,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        (address tokenToPay, address vTokenToPay) = venusMapping.getMapping(
            tokenIdToPay
        );
        (address tokenInReturn, address vTokenColl) = venusMapping.getMapping(
            tokenIdInReturn
        );

        (_eventName, _eventParam) = liquidateRaw(
            borrower,
            tokenToPay,
            vTokenToPay,
            tokenInReturn,
            vTokenColl,
            amt,
            getId,
            setId
        );
    }
}

contract ConnectorV2Venus is VenusResolver {
    string public name = "Venus-v1";
    constructor(address venusMapping) Helpers(venusMapping){}
}

pragma solidity ^0.7.0;

interface TokenInterface {
    function approve(address, uint256) external;

    function transfer(address, uint256) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function deposit() external payable;

    function withdraw(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function decimals() external view returns (uint256);
}

interface MemoryInterface {
    function getUint(uint256 id) external returns (uint256 num);

    function setUint(uint256 id, uint256 val) external;
}

interface NbnMapping {
    function vTokenMapping(address) external view returns (address);

    function gemJoinMapping(bytes32) external view returns (address);
}

interface AccountInterface {
    function enable(address) external;

    function disable(address) external;

    function isAuth(address) external view returns (bool);
}

pragma solidity ^0.7.0;

import {MemoryInterface, NbnMapping} from "./interfaces.sol";

abstract contract Stores {
    /**
     * @dev Return ethereum address
     */
    address internal constant ethAddr =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @dev Return Wrapped BNB address
     */
    address internal constant wethAddr =
        0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    /**
     * @dev Return memory variable address
     */
    MemoryInterface internal constant NbnMemory =
        MemoryInterface(0x9a303550013eCd11d429A4C142a3987C6c9814C4);

    /**
     * @dev Return NbnDApp Mapping Addresses
     */
    NbnMapping internal constant nbnMapping =
        NbnMapping(0x5DDa94995d64fB239F7dE2971E90a36524605b52);

    /**
     * @dev Get Uint value from NbnMemory Contract.
     */
    function getUint(uint256 getId, uint256 val)
        internal
        returns (uint256 returnVal)
    {
        returnVal = getId == 0 ? val : NbnMemory.getUint(getId);
    }

    /**
     * @dev Set Uint value in NbnMemory Contract.
     */
    function setUint(uint256 setId, uint256 val) internal virtual {
        if (setId != 0) NbnMemory.setUint(setId, val);
    }
}

pragma solidity ^0.7.0;

import {DSMath} from "../common/math.sol";
import {Basic} from "../common/basic.sol";
import {UniTrollerInterface, VenusMappingInterface} from "./interface.sol";

abstract contract Helpers is DSMath, Basic {
    /**
     * @dev Venus Comptroller
     */
    UniTrollerInterface internal constant troller =
        UniTrollerInterface(0xfD36E2c2a6789Db23113685031d7F16329158384);

    /**
     * @dev Venus mapping
     */
    VenusMappingInterface internal immutable venusMapping;

    constructor(address _venusMapping){
        venusMapping = VenusMappingInterface(_venusMapping);
    }

    /**
     * @dev enter Venus market
     */
    function enterMarket(address vToken) internal {
        address[] memory markets = troller.getAssetsIn(address(this));
        bool isEntered = false;
        for (uint256 i = 0; i < markets.length; i++) {
            if (markets[i] == vToken) {
                isEntered = true;
            }
        }
        if (!isEntered) {
            address[] memory toEnter = new address[](1);
            toEnter[0] = vToken;
            troller.enterMarkets(toEnter);
        }
    }
}

pragma solidity ^0.7.0;

contract Events {
    //supply an asset
    event LogDeposit(
        address indexed token,
        address vToken,
        uint256 tokenAmt,
        uint256 getId,
        uint256 setId
    );

    //redeem deposits
    event LogWithdraw(
        address indexed token,
        address vToken,
        uint256 tokenAmt,
        uint256 getId,
        uint256 setId
    );

    //borrow an asset
    event LogBorrow(
        address indexed token,
        address vToken,
        uint256 tokenAmt,
        uint256 getId,
        uint256 setId
    );

    //repay back an asset
    event LogPayback(
        address indexed token,
        address vToken,
        uint256 tokenAmt,
        uint256 getId,
        uint256 setId
    );

    //deposit vTokens
    event LogDepositVToken(
        address indexed token,
        address vToken,
        uint256 tokenAmt,
        uint256 vTokenAmt,
        uint256 getId,
        uint256 setId
    );
    //withdraw vtokens
    event LogWithdrawVToken(
        address indexed token,
        address vToken,
        uint256 tokenAmt,
        uint256 vTokenAmt,
        uint256 getId,
        uint256 setId
    );

    //liquidate borrow
    event LogLiquidate(
        address indexed borrower,
        address indexed tokenToPay,
        address indexed tokenInReturn,
        uint256 tokenAmt,
        uint256 getId,
        uint256 setId
    );
}

pragma solidity ^0.7.0;

interface VTokenInterface {
    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function repayBorrowBehalf(address borrower, uint256 repayAmount)
        external
        returns (uint256);

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        VTokenInterface vTokenCollateral
    ) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);
}

interface VETHInterface {
    function mint() external payable;

    function repayBorrow() external payable;

    function repayBorrowBehalf(address borrower) external payable;

    function liquidateBorrow(address borrower, address vTokenCollateral)
        external
        payable;
}

interface UniTrollerInterface {
    function enterMarkets(address[] calldata vTokens)
        external
        returns (uint256[] memory);

    function exitMarket(address vTokenAddress) external returns (uint256);

    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getAssetsIn(address account)
        external
        view
        returns (address[] memory);
}

interface VenusMappingInterface {
    function vTokenMapping(string calldata tokenId)
        external
        view
        returns (address);

    function getMapping(string calldata tokenId)
        external
        view
        returns (address, address);
}

pragma solidity ^0.7.0;

import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

contract DSMath {
  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function add(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(x, y);
  }

  function sub(uint x, uint y) internal virtual pure returns (uint z) {
    z = SafeMath.sub(x, y);
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.mul(x, y);
  }

  function div(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.div(x, y);
  }

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
  }

  function rmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
  }

  function toInt(uint x) internal pure returns (int y) {
    y = int(x);
    require(y >= 0, "int-overflow");
  }

  function toRad(uint wad) internal pure returns (uint rad) {
    rad = mul(wad, 10 ** 27);
  }

}

pragma solidity ^0.7.0;

import { TokenInterface } from "./interfaces.sol";
import { Stores } from "./stores.sol";
import { DSMath } from "./math.sol";

abstract contract Basic is DSMath, Stores {

    function convert18ToDec(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = (_amt / 10 ** (18 - _dec));
    }

    function convertTo18(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = mul(_amt, 10 ** (18 - _dec));
    }

    function getTokenBal(TokenInterface token) internal view returns(uint _amt) {
        _amt = address(token) == ethAddr ? address(this).balance : token.balanceOf(address(this));
    }

    function getTokensDec(TokenInterface buyAddr, TokenInterface sellAddr) internal view returns(uint buyDec, uint sellDec) {
        buyDec = address(buyAddr) == ethAddr ?  18 : buyAddr.decimals();
        sellDec = address(sellAddr) == ethAddr ?  18 : sellAddr.decimals();
    }

    function encodeEvent(string memory eventName, bytes memory eventParam) internal pure returns (bytes memory) {
        return abi.encode(eventName, eventParam);
    }

    function changeEthAddress(address buy, address sell) internal pure returns(TokenInterface _buy, TokenInterface _sell){
        _buy = buy == ethAddr ? TokenInterface(wethAddr) : TokenInterface(buy);
        _sell = sell == ethAddr ? TokenInterface(wethAddr) : TokenInterface(sell);
    }

    function convertEthToWeth(bool isEth, TokenInterface token, uint amount) internal {
        if(isEth) token.deposit{value: amount}();
    }

    function convertWethToEth(bool isEth, TokenInterface token, uint amount) internal {
       if(isEth) {
            token.approve(address(token), amount);
            token.withdraw(amount);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}