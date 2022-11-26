// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

import "./utils/SafeMath.sol";
import "./utils/SafeERC20.sol";
import "./utils/LowGasSafeMath.sol";
import "./utils/BondOwnable.sol";
import "./utils/Address.sol";
import "./utils/interfaces/IERC20.sol";
import "./zap/interfaces/IZap.sol";

contract Treasury is BondOwnable {

    using LowGasSafeMath for uint;
    using LowGasSafeMath for uint32;
    using SafeERC20 for IERC20;

    event Deposit( address indexed token, uint amount, uint value );
    event BondContractToggled(address bondContract, bool approved);
    event Withdraw(address token, address destination, uint amount);
    //event ClaimAirdrop(address airdropToken, uint airdropAmount);
    event ReservesManaged( address indexed token, uint amount );
    event ReservesUpdated( uint indexed totalReserves );
    event ReservesAudited( uint indexed totalReserves );
    event RewardsMinted( address indexed caller, address indexed recipient, uint amount );
    event ChangeLimitAmount( uint256 amount );

    address public immutable payoutToken;
    mapping(address => bool) public bondContract; 
    address[] public reserveTokens; // Push only, beware false-positives.
    mapping( address => bool ) public isReserveToken;
    address[] public liquidityTokens; // Push only, beware false-positives.
    mapping( address => bool ) public isLiquidityToken;
    mapping( address => uint256 ) public hourlyLimitAmounts; // tracks amounts
    mapping( address => uint32 ) public hourlyLimitQueue; // Delays changes to mapping.

    uint256 public limitAmount;
    //address public immutable airdropToken;
    //uint    public immutable airdropRatio; // int
    address public immutable scholar;
    address public immutable foundation;
    address public immutable dao;
    bool public immutable isZap;
    address public immutable initialOwner; // address of contract creator


    uint public totalReserves; // Risk-free value of all assets
    uint public totalDebt;
    IZap public immutable Zap;

    constructor (
        address _payoutToken, // to payoutToken
        address _principle, // liquidityToken (payment)
        //address _airdropToken, // address token
        //uint _airdropRatio, // payout / airdrop ratio
        address _scholar, 
        address _foundation, 
        address _dao,
        uint256 _limitAmount,
        address _Zap,
        address _initialOwner
    ) BondOwnable(_initialOwner){
        require( _payoutToken != address(0) );
        payoutToken = _payoutToken;
        isReserveToken[ _payoutToken ] = true;
        reserveTokens.push( _payoutToken );
        isLiquidityToken[ _principle ] = true;
        liquidityTokens.push( _principle );
        //require( _airdropToken != address(0) );
        //airdropToken = _airdropToken;
        //airdropRatio = _airdropRatio;
        require( _scholar != address(0) );
        scholar = _scholar;
        require( _foundation != address(0) );
        foundation = _foundation;
        require( _dao != address(0) );
        dao = _dao;
        limitAmount = _limitAmount;
        Zap = IZap(_Zap);
        isZap = (_Zap != address(0));
        require( _initialOwner != address(0) );
        initialOwner = _initialOwner;
    }

    function setLimitAmount(uint amount) external onlyAdmin {
        limitAmount = amount;
        emit ChangeLimitAmount(limitAmount);
    }

    /* ======== BOND CONTRACT FUNCTION ======== */

    function deposit(address _principleTokenAddress, 
    uint _amountPrincipleToken, 
    uint _amountPayoutToken, 
    address _LP) external {
        require(bondContract[msg.sender], "msg.sender is not a bond contract");

        //uint toFoundation = _amountPrincipleToken.div(100).mul(25);
        //uint toScholar = _amountPrincipleToken.div(100).mul(10);
        //uint toDao = _amountPrincipleToken.div(100).mul(65);

        //Integrate IZap to convert payin in LP
        if (isZap) {
            //IERC20(_principleTokenAddress).approve(address(Zap), _amountPrincipleToken);
            Zap.zapInToken(_principleTokenAddress, _amountPrincipleToken, _LP );
            IERC20(_LP).safeTransferFrom(msg.sender, address(dao), _amountPrincipleToken);
        
        } else {
            IERC20(_principleTokenAddress).safeTransferFrom(msg.sender, address(dao), _amountPrincipleToken);
        }

        //IERC20(_principleTokenAddress).safeTransferFrom(msg.sender, address(scholar), toScholar);
        //IERC20(_principleTokenAddress).safeTransferFrom(msg.sender, address(foundation), toFoundation);
        //IERC20(_principleTokenAddress).safeTransferFrom(msg.sender, address(dao), toDao);

        IERC20(payoutToken).safeTransfer(msg.sender, _amountPayoutToken);
        
        emit Deposit( _principleTokenAddress, _amountPrincipleToken, _amountPayoutToken );
    }

    /* ======== VIEW FUNCTION ======== */
    
    function valueOf( address _principleTokenAddress, uint _amount ) public view returns ( uint value_ ) {
        // convert amount to match payout token decimals
        value_ = _amount.mul(
             10 ** IERC20( payoutToken ).decimals() ).div( 10 ** IERC20( _principleTokenAddress ).decimals() );
    }

    /* ======== POLICY FUNCTIONS ======== */

    function withdraw(address _token, address _destination, uint _amount) external onlyAdmin(){
        IERC20(_token).safeTransfer(_destination, _amount);

        emit Withdraw(_token, _destination, _amount);
    }

    /* function claimAirdrop(address _airdropToken, uint _airdropAmount) external {
        require(bondContract[msg.sender], "msg.sender is not a bond contract");
            IERC20(_airdropToken).safeTransfer(msg.sender, _airdropAmount);

            emit ClaimAirdrop(_airdropToken, _airdropAmount);
    } */

    function recoverLostETH() external onlyAdmin() returns ( bool ) {
        if (address(this).balance > 0) safeTransferETH(dao, address(this).balance);
        return true;
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }

    function toggleBondContract(address _bondContract) external onlyAdmin() {
        bondContract[_bondContract] = !bondContract[_bondContract];

        emit BondContractToggled(_bondContract, bondContract[_bondContract]);
    }

    function auditReserves() external onlyAdmin {
        uint reserves;
        for( uint i = 0; i < reserveTokens.length; i++ ) {
            reserves = reserves.add ( 
                valueOf( reserveTokens[ i ], IERC20( reserveTokens[ i ] ).balanceOf( address(this) ) )
            );
        }
        for( uint i = 0; i < liquidityTokens.length; i++ ) {
            reserves = reserves.add (
                valueOf( liquidityTokens[ i ], IERC20( liquidityTokens[ i ] ).balanceOf( address(this) ) )
            );
        }
        totalReserves = reserves;
        emit ReservesUpdated( reserves );
        emit ReservesAudited( reserves );
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

library LowGasSafeMath {
    /// @notice Returns x + y, reverts if sum overflows uint256
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function add32(uint32 x, uint32 y) internal pure returns (uint32 z) {
        require((z = x + y) >= x);
    }

    /// @notice Returns x - y, reverts if underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function sub32(uint32 x, uint32 y) internal pure returns (uint32 z) {
        require((z = x - y) <= x);
    }

    /// @notice Returns x * y, reverts if overflows
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @return z The product of x and y
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    function mul32(uint32 x, uint32 y) internal pure returns (uint32 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    /// @notice Returns x + y, reverts if overflows or underflows
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    /// @notice Returns x - y, reverts if overflows or underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }

    function div(uint256 x, uint256 y) internal pure returns(uint256 z){
        require(y > 0);
        z=x/y;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

import "./LowGasSafeMath.sol";
import "./Address.sol";
import "./interfaces/IERC20.sol";

library SafeERC20 {
    using LowGasSafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

contract BondOwnable {

    address public admin;

    constructor (address _initialAdmin) {
        admin = _initialAdmin;
    }

    modifier onlyAdmin() {
        require( admin == msg.sender, "Ownable: caller is not the owner" );
        _;
    }
    
    function transferManagment(address _newOwner) external onlyAdmin() {
        require( _newOwner != address(0) );
        admin = _newOwner;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

library Address {

  function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function functionCall(
        address target, 
        bytes memory data, 
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function _functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 weiValue, 
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function _verifyCallResult(
        bool success, 
        bytes memory returndata, 
        string memory errorMessage
    ) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

interface IZap {
    function zapOut(address _from, uint amount) external;
    function zapIn(address _to) external payable;
    function zapInToken(address _from, uint amount, address _to) external;
}