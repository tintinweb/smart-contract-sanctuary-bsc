/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IPanscakeV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
  external
  payable
  returns (uint[] memory amounts);
function swapExactTokensForETHSupportingFeeOnTransferTokens(
  uint amountIn,
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
) external;

function WETH() external pure returns (address);

  function swapExactTokensForTokens(
  
    //amount of tokens we are sending in
    uint256 amountIn,
    //the minimum amount of tokens we want out of the trade
    uint256 amountOutMin,
    //list of token addresses we are going to trade in.  this is necessary to calculate amounts
    address[] calldata path,
    //this is the address we are going to send the output tokens to
    address to,
    //the last time that the trade is valid for
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}


interface IPanscakeV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IPanscakeV2Factory {
  function getPair(address token0, address token1) external returns (address);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 {
    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function getMintTime(uint _tokenId) external view returns(uint);

}

contract RewardDividendDistributor {
    using SafeMath for uint256;

    address public _owner;
    address public token;
    address public minerNFT;

    struct Share {
        uint256 claimedAt;
        uint256 totalClaimed;
        uint256 nftMaxClaimedCount;
    }

    struct Dividend {
        uint256 perNFTShare;
        uint256 depositTime;
    }
 event Received(address, uint);
    receive() external payable {
        send();
        emit Received(msg.sender, msg.value);
    }
    mapping(uint256 => Share) public shares;
    // mapping(uint256 => uint256) public nftMintTime;
    mapping(uint256 => Dividend) public dividendHistory;
    // mapping(uint256 => uint256) public nftMaxClaimedCount;
    mapping(address => uint256) public shareholderTotalClaimed;

    uint256 public depositCount;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor;
    address public allowedCaller;
    

    address PANSCAKE_ROUTER;
    uint public swapLimit;

    event DEPOSIT(uint256 _time, uint256 _depositAmount);

    modifier onlyOwner() {
        require(msg.sender == _owner || msg.sender==allowedCaller, "Only Owner Allowed");
        _;
    }

    constructor(
        address router_,
        address token_,
        address _nftAddr
    ) {
        token = token_;
        _owner = msg.sender;
        minerNFT = _nftAddr;
        PANSCAKE_ROUTER = router_;
        swapLimit = 0.000001 ether;

        dividendsPerShareAccuracyFactor = 10**36;
    }
 

function setRouter(address _contract) public  onlyOwner {
    PANSCAKE_ROUTER = _contract;
}


function member(
        address token_,
        address owner_,
        address _nftAddr
) public onlyOwner{
        token = token_;
        _owner = owner_;
        minerNFT = _nftAddr;

}

    function claimMinedReward() public {
        distributeDividend(msg.sender);
    }

    // ======================== View Functions ========================
    function getPaidEarnings(address shareholder) public view returns (uint256 _tPaidShare) {
        uint256 balances = IERC721(minerNFT).balanceOf(shareholder);
        for (uint256 i = 0; i < balances; i++) {
            uint256 curId = IERC721(minerNFT).tokenOfOwnerByIndex(shareholder, i);
            _tPaidShare += shares[curId].totalClaimed;
        }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        uint256 nftsBalance = IERC721(minerNFT).balanceOf(shareholder);
        uint256 shareholderTotalDividends;
        // uint256 shareholderTotalExcluded;
        for (uint256 i = 0; i < nftsBalance; i++) {
            uint256 curId = IERC721(minerNFT).tokenOfOwnerByIndex(shareholder, i);
            uint256 __nftMaxCount = shares[curId].nftMaxClaimedCount;
            for (uint256 j = __nftMaxCount; j < depositCount; j++) {
                if (dividendHistory[j].depositTime >= IERC721(minerNFT).getMintTime(curId)) {
                    shareholderTotalDividends = shareholderTotalDividends.add(
                        getCumulativeDividends(10**decimals(), dividendHistory[j].perNFTShare)
                    );
                }
            }
            // shareholderTotalExcluded = shareholderTotalExcluded.add(shares[curId].totalClaimed);
        }

        // if (shareholderTotalDividends <= shareholderTotalExcluded) {
        //     return 0;
        // }

        return shareholderTotalDividends;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    // ======================== Internal Functions ========================
    function distributeDividend(address shareholder) internal {
        uint256 ownedShare = IERC721(minerNFT).balanceOf(shareholder);
        require(ownedShare != 0, "Dont have any share!");

        uint256 amount;
        totalDistributed = totalDistributed.add(amount);
        shareholderTotalClaimed[shareholder] = shareholderTotalClaimed[shareholder].add(amount);

        uint256 _nfBalance = IERC721(minerNFT).balanceOf(shareholder);
        uint256 i;
        while (i < _nfBalance) {
            uint256 currId = IERC721(minerNFT).tokenOfOwnerByIndex(shareholder, i);
            uint256 currentDividend;
            for (uint256 j = shares[currId].nftMaxClaimedCount; j < depositCount; j++) {
                if (dividendHistory[j].depositTime >= IERC721(minerNFT).getMintTime(currId)) {
                    currentDividend = currentDividend.add(
                        getCumulativeDividends(10**decimals(), dividendHistory[j].perNFTShare)
                    );
                    shares[currId].nftMaxClaimedCount = j + 1;
                }
            }
            if (currentDividend == 0) {
                continue;
            }

            amount += currentDividend;
            shares[currId].claimedAt = block.timestamp;
            shares[currId].totalClaimed = shares[currId].totalClaimed.add(currentDividend);
            i++;
        }
        require(amount > 0, "Insufficient Amount to claim!");
        IERC20(token).transfer(shareholder, amount);
    }

    function getCumulativeDividends(uint256 share, uint256 perShare) internal view returns (uint256) {
        return share.mul(perShare).div(dividendsPerShareAccuracyFactor);
    }

    // ======================== Owner's Functions ========================

    function updateOwnership(address _newOwner) external onlyOwner {
        _owner = _newOwner;
    }

    function setToken(address _tokenAddr) external onlyOwner {
        require(_tokenAddr != address(0), "Invalid address.");
        token = _tokenAddr;
    }

    function setNFT(address _nft) external onlyOwner {
        require(_nft != address(0), "Invalid address.");
        minerNFT = _nft;
    }

    function deposit(uint256 _minedReward) public  onlyOwner{
        // IERC20(token).transferFrom(msg.sender, address(this), _minedReward);
        totalShares = IERC721(minerNFT).totalSupply() * (10**decimals());

        uint256 depositIndex = depositCount++;
        dividendHistory[depositIndex].depositTime = block.timestamp;
        dividendHistory[depositIndex].perNFTShare = dividendsPerShareAccuracyFactor.mul(IERC20(token).balanceOf(address(this))).div(totalShares);

        totalDividends = totalDividends.add(_minedReward);
        dividendsPerShare = dividendsPerShare.add(dividendHistory[depositIndex].perNFTShare);

        emit DEPOSIT(block.timestamp, _minedReward);
    }

     function send() public payable onlyOwner  returns (bool) {
        uint256 bc = address(this).balance;
        if (bc >= swapLimit) {
            //   address payable walletR = payable (financeContract) ;
            uint amount = swap(
                IPanscakeV2Router(PANSCAKE_ROUTER).WETH(),
                token,
                bc,
                0,
                address(this)
            );

            deposit(0);
        }
        return true;
    }
    
    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) public returns(uint){
   
        address[] memory path;
        if (_tokenIn == IPanscakeV2Router(PANSCAKE_ROUTER).WETH()|| _tokenOut == IPanscakeV2Router(PANSCAKE_ROUTER).WETH()) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = IPanscakeV2Router(PANSCAKE_ROUTER).WETH();
            path[2] = _tokenOut;
        }
    
         (uint[] memory amounts)=IPanscakeV2Router(PANSCAKE_ROUTER).swapExactETHForTokens{
            value: _amountIn
        }(_amountOutMin, path, _to, block.timestamp+30);

        return amounts[1];
    }
 

    function withdrawStuckTokens(
        address _user,
        address _tokenAddr,
        uint256 _amount
    ) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        IERC20(_tokenAddr).transfer(_user, _amount);
    }

   
   

    function withdrawFunds(address _user, uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        payable(_user).transfer(_amount);
    }
    function changeRewardToken(address _token) external onlyOwner {
        token= _token;
     }
    function setMarketplaceAddress(address _market) external onlyOwner {
        allowedCaller= _market;
     }
    function changeSwapLimit(uint _value) external onlyOwner {
        swapLimit = _value;
     }
}