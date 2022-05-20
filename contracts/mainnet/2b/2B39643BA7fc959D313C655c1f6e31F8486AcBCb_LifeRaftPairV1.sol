/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract LifeRaftPairV1 {
    mapping(address => uint256) public entryPrice;
    mapping(address => uint256) public userBalance;
    mapping(address => bool) public isStaked;
    address private _owner; 
    uint256 public stakingFee = 0;
    bool public flippedDivisor = false;

    IERC20 assetToken = IERC20(0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD);
    IERC20 raftToken = IERC20(0xbBBc95172E0C7a793F3646a567ED2D10EdFA6699);
    IERC20 tankToken = IERC20(0xBfCe82c2bed5dD88CABF01F25229D7d43aCC5CA9);
    IPancakePair AssetBnbPair = IPancakePair(0x824eb9faDFb377394430d2744fa7C42916DE3eCe);
    IPancakePair RaftBnbPair = IPancakePair(0x25c4427E5C586109942FEddEdd88B7C9BEaB486B);
    IPancakePair TankBnbPair = IPancakePair(0x2C8C7224EB2B2F2F4EE151BfC0F1a1ef180323B4);

    uint256 public assetDecimals = 18;

    function setStakingFee (uint _amount) public {
        require(msg.sender == _owner, "Only the team may do this.");
        stakingFee = _amount;
    }
    function recoverFees () public{
        require(msg.sender == _owner, "Only the team may do this.");
        payable(msg.sender).transfer(address(this).balance);
    }

    function testSetValues (uint _entry, uint _userBalance ) public {
        require(msg.sender == _owner, "Only the team may do this.");
        isStaked[msg.sender] = true;
        userBalance[msg.sender] = _userBalance;
        entryPrice[msg.sender] = _entry;
    }

    function flipDivisor () public returns (bool) {
        require(msg.sender == _owner, "Only the team may do this.");
        flippedDivisor = !flippedDivisor;
        return flippedDivisor;
    }
    constructor(){
        _owner = msg.sender;
    }

    function getQuote (IPancakePair _pair) public view returns(uint112 assetReserve, uint112 baseReserve, uint32 lastTimeStamp){
        return _pair.getReserves();
    } 

    function GetAssetPrice (IPancakePair _pair) public view returns(uint112){
        (uint112 assetReserve, uint112 baseReserve, uint32 stamp) = getQuote(_pair);
        uint112 assetPrice;
        if (flippedDivisor == false){
            assetPrice = (baseReserve / assetReserve);
        }else{
            assetPrice = (assetReserve / baseReserve);
        }
        
        return assetPrice;
    }

    function getRaftTankPrice (IPancakePair _pair) public view returns(uint112){
        (uint112 assetReserve, uint112 baseReserve, uint32 stamp) = getQuote(_pair);
        uint112 assetPrice;
        if (baseReserve > assetReserve){
            assetPrice = (baseReserve / assetReserve);
        }else{
            assetPrice = (assetReserve / baseReserve);
        }
        
        return assetPrice;
    }

    
    function StakeAsset(uint256 _amount) public payable {
        require(msg.value == stakingFee, "Insufficient Fee Amount");
        assetToken.transferFrom(msg.sender, address(this), _amount);
        entryPrice[msg.sender] = GetAssetPrice(AssetBnbPair);
        isStaked[msg.sender] = true;
        userBalance[msg.sender] = _amount;
    }

    function GetRewards() public{
        require(isStaked[msg.sender] == true, "You have no assets staked.");
        uint lastPrice = uint256(GetAssetPrice(AssetBnbPair));
        uint userEntry = uint256(entryPrice[msg.sender]);
        uint userPayout;
        if (lastPrice > userEntry){
            uint difference = lastPrice - userEntry;
            uint tankPrice = uint256(getRaftTankPrice(TankBnbPair));
            userPayout = ((tankPrice / userEntry) - (tankPrice / lastPrice)) * userBalance[msg.sender];
            tankToken.mint(address(this), userPayout);
            tankToken.transfer(msg.sender, userPayout);
            assetToken.transfer(msg.sender, userBalance[msg.sender]);
            userBalance[msg.sender] = 0;
            entryPrice[msg.sender] = 0;
            isStaked[msg.sender] = false;
        } else if (lastPrice < userEntry){
            uint difference = userEntry - lastPrice;
            uint raftPrice = uint256(getRaftTankPrice(RaftBnbPair));
            userPayout = ((raftPrice / lastPrice) - (raftPrice / userEntry)) * userBalance[msg.sender];
            raftToken.mint(address(this), userPayout);
            raftToken.transfer(msg.sender, userPayout);
            assetToken.transfer(msg.sender, userBalance[msg.sender]);
            userBalance[msg.sender] = 0;
            entryPrice[msg.sender] = 0;
            isStaked[msg.sender] = false;
        } else if (lastPrice == userEntry){
            assetToken.transfer(msg.sender, userBalance[msg.sender]);
            userBalance[msg.sender] = 0;
            entryPrice[msg.sender] = 0;
            isStaked[msg.sender] = false;
        }


    }

    function checkRewards(address _address) public view returns(uint, bool, uint, uint, uint) {
        uint lastPrice = uint256(GetAssetPrice(AssetBnbPair));
        uint userEntry = uint256(entryPrice[_address]);
        uint userPayout;
        bool isRaft;
        if (userEntry == 0){
            return(0, true, 0, lastPrice, userBalance[msg.sender]);
        }else if (lastPrice > userEntry){
            isRaft = false;
            uint difference = lastPrice - userEntry;
            uint tankPrice = uint256(getRaftTankPrice(TankBnbPair));
            userPayout = ((tankPrice / userEntry) - (tankPrice / lastPrice)) * userBalance[msg.sender];
            return(userPayout, isRaft, userEntry, lastPrice, userBalance[msg.sender]);
        } else{
            isRaft = true;
            uint difference = userEntry - lastPrice;
            uint raftPrice = uint256(getRaftTankPrice(RaftBnbPair));
            userPayout = ((raftPrice / lastPrice) - (raftPrice / userEntry)) * userBalance[msg.sender];
            return(userPayout, isRaft, userEntry, lastPrice, userBalance[msg.sender]);
        }
    }


}


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);


    function mint(address to, uint256 value) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}