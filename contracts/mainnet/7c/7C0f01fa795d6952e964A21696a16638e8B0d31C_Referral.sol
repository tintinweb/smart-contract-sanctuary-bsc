/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline,  bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Referral is ERC721TokenReceiver {
    using SafeMath for uint256;

    address public owner;
    bool public enabled;

    uint public baseRate;
    uint public tier0Royalties;
    uint public tier1Royalties;
    uint public tier2Royalties;
    uint public tier3Royalties;
    uint public maxRoyalties;
    uint public maxStake;

    address private _wbnb;
    address private _token;

    IERC20 private _tokenContract;
    IERC721 private _nftContract;
    IDEXRouter private _router;

    struct Referrer {
        address who;
        uint amount;
        uint sum;
        uint paid;
    }

    struct Transaction {
        address who;
        uint amount;
        uint commission;
    }

    mapping (address => uint) private _referrerIndex;
    mapping(address => uint[]) private _stakedTokenIds;
    mapping (address => Transaction[]) private _transactions;
    mapping(uint => address) private _tokenOwners;

    Referrer[] private _referrers;

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by the contract owner");
        _;
    }

    modifier whenEnabled() {
        require(enabled || msg.sender == owner, "exchange not enabled");
        _;
    }

    constructor() {
        owner = msg.sender;
        baseRate = 30;
        tier0Royalties = 5; 
        tier1Royalties = 10;
        tier2Royalties = 20;
        tier3Royalties = 50;
        maxRoyalties = 500;
        maxStake = 5;

        enabled = true;

        //address pancakeSwap = 0xc99f3718dB7c90b020cBBbb47eD26b0BA0C6512B; // TESTNET - https://pancakeswap.rainbit.me/
        //_token = 0x69E17b7c747F04F85bB4Cd3ad25F7C99c7F96FBD;
        //_tokenContract = IERC20(_token);
        //_nftContract = IERC721(0x58992005849482AA9886A88A175DBBD129f35CE5);

        address pancakeSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // MAINNET
        _token = 0xb6706046E2AB6Bf9e6b4e84684be1d98dD1fF4AB;
        _tokenContract = IERC20(_token);
        _nftContract = IERC721(0xa850C097a855601dfe04331Ec83E3d828bb15995);

        _router = IDEXRouter(pancakeSwap);
        _wbnb = _router.WETH();
 
        _referrers.push(Referrer(address(0), 0, 0, 0));
    }

    function info(uint id) external view returns (bool isValid, bool isEnabled, bool isReferrer, uint referrerId, uint royalties, uint[] memory staked) {
        isValid = _referrers[id].who != address(0) && _referrers[id].who != msg.sender;
        isReferrer = _referrerIndex[msg.sender] != 0;
        referrerId = _referrerIndex[msg.sender];
        isEnabled = enabled;
        royalties = calculateRoyalties(msg.sender);
        staked = new uint[](maxStake);
        for (uint i = 0; i < _stakedTokenIds[msg.sender].length; i++) {
            staked[i] = _stakedTokenIds[msg.sender][i];
        }
    }

    function getScoreboard() external view returns (address[] memory addresses, uint[] memory amounts) {
        addresses = new address[](_referrers.length);
        amounts = new uint[](_referrers.length);
        for (uint i = 0; i < _referrers.length; i++) {
            addresses[i] = _referrers[i].who;
            amounts[i] = _referrers[i].amount;
        }

    }

    function getTransactions() external view returns (uint totalAmount, uint totalCommission, address[] memory addresses, uint[] memory amounts, uint[] memory commission) {
        if (_referrerIndex[msg.sender] > 0) {
        
            totalAmount = _referrers[_referrerIndex[msg.sender]].amount;
            totalCommission = _referrers[_referrerIndex[msg.sender]].paid;

            addresses = new address[](10);
            amounts = new uint[](10);
            commission = new uint[](10);

            if (_transactions[msg.sender].length > 0) {
                uint limit = 0;
                if (_transactions[msg.sender].length > 10) {
                    limit = _transactions[msg.sender].length - 10;
                }

                uint x = 0;
                for (uint i = limit; i < _transactions[msg.sender].length; i++) {
                    addresses[x] = _transactions[msg.sender][i].who;
                    amounts[x] = _transactions[msg.sender][i].amount;
                    commission[x] = _transactions[msg.sender][i].commission;
                    x++;        
                }
            }
        }
    }

    function register() external whenEnabled {
        require(_referrerIndex[msg.sender] == 0, "Already Registered");
        _referrerIndex[msg.sender] = _referrers.length;
        _referrers.push(Referrer(msg.sender, 0, 0, 0));
    }

    function quote(uint amount) public whenEnabled view returns (uint[] memory) {
        address[] memory path = new address[](2);
        path[0] = _wbnb;
        path[1] = _token;

        return _router.getAmountsOut(amount, path);
    }

    function buy(uint referrer, uint amount, uint minOut) external whenEnabled payable {
        require(_referrers[referrer].who != address(0), "this account is not a registered referrer");
        require(_referrers[referrer].who != msg.sender, "you cannot refer your own transactions");
        require(amount <= msg.value, "Incorrect amount supplied");

        address[] memory path = new address[](2);
        path[0] = _wbnb;
        path[1] = _token;

        _router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value }(minOut, path, msg.sender, block.timestamp + 300);

        uint royalties = calculateRoyalties(_referrers[referrer].who);
        uint royaltyAmount = quote(amount.mul(royalties).div(1000))[1];

        _referrers[referrer].sum ++;
        _referrers[referrer].amount += msg.value;
        _referrers[referrer].paid += royaltyAmount;
        
        // Send to person
        _tokenContract.transfer(_referrers[referrer].who, royaltyAmount);
        _transactions[_referrers[referrer].who].push(Transaction(msg.sender, amount, royaltyAmount));
    }

    function stake(uint tokenId) whenEnabled external {
        require(_nftContract.getApproved(tokenId) == address(this), "Must approve this contract as an operator");
        _nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
        _stakedTokenIds[msg.sender].push(tokenId);
        _tokenOwners[tokenId] = msg.sender;
    }

    function unstake(uint tokenId) whenEnabled external {
        bool found;
        for (uint i = 0; i < _stakedTokenIds[msg.sender].length; i++) {
            if (tokenId == _stakedTokenIds[msg.sender][i]) {
                found = true;
                if (_stakedTokenIds[msg.sender].length > 1) {
                    _stakedTokenIds[msg.sender][i] = _stakedTokenIds[msg.sender][_stakedTokenIds[msg.sender].length - 1];
                }
                _stakedTokenIds[msg.sender].pop();
                _nftContract.safeTransferFrom(address(this), msg.sender, tokenId);
                break;
            }
        }

        require(found, "You have not staked this token");
    }

    function onERC721Received(address, address, uint256, bytes memory) public pure override returns(bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }


    // Admin

    function setOwner(address who) external onlyOwner {
        owner = who;
    }

    function setRates(uint _base, uint _tier0, uint _tier1, uint _tier2, uint _tier3, uint _max, uint _stake) external onlyOwner {
        baseRate = _base;
        tier0Royalties = _tier0;
        tier1Royalties = _tier1;
        tier2Royalties = _tier2;
        tier3Royalties = _tier3;
        maxRoyalties = _max;
        maxStake = _stake;
    }

    function setEnabled(bool on) external onlyOwner {
        enabled = on;
    }

    function removeAllTokens() external onlyOwner {
        _tokenContract.transfer(owner, _tokenContract.balanceOf(address(this)));
    }

    function forceRemoveNft(uint tokenId) external onlyOwner {
        _nftContract.safeTransferFrom(address(this), _tokenOwners[tokenId], tokenId);
    }


    // Private

    function calculateRoyalties(address who) private view returns (uint royalties) {
        royalties += baseRate;

        for (uint i =- 0; i < _stakedTokenIds[who].length; i++) {
            string memory tokenUri = _nftContract.tokenURI(_stakedTokenIds[who][i]);
            if (contains("nftstorage.link/600/", tokenUri)) {
                royalties += tier0Royalties;
            }
            if (contains("nftstorage.link/300/", tokenUri)) {
                royalties += tier1Royalties;
            }
            if (contains("nftstorage.link/30/", tokenUri)) {
                royalties += tier2Royalties;
            }
            if (contains("nftstorage.link/3/", tokenUri)) {
                royalties += tier3Royalties;
            }
        }

        if (royalties > maxRoyalties) {
            royalties = maxRoyalties;
        }
    }

    function contains(string memory what, string memory where) private pure returns (bool) {
        bytes memory whatBytes = bytes (what);
        bytes memory whereBytes = bytes (where);

        require(whereBytes.length >= whatBytes.length);

        bool found = false;
        for (uint i = 0; i <= whereBytes.length - whatBytes.length; i++) {
            bool flag = true;
            for (uint j = 0; j < whatBytes.length; j++)
                if (whereBytes [i + j] != whatBytes [j]) {
                    flag = false;
                    break;
                }
            if (flag) {
                found = true;
                break;
            }
        }
        return found;
    }
}