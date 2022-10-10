/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.6; 6或者0都可以
pragma solidity ^0.8.0;

interface GlodContract{
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function transfer(address recipient,uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function toMint(address to,uint256 amount) external returns (bool);
    function toBurn(address to,uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface Team{
    function team(address from_) external returns (address);
    function bindingWhite(address from_ , address to_) external returns (bool);
}

interface ISwapRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) 
        external 
        returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut,uint amountInMax,address[] calldata path,address to,uint deadline) 
        external 
        returns (uint[] memory amounts);

}

contract Patern{
    //上下级合约
    address public TeamContract = address(0x01fd311Ded4C90B2Fa3fFd2759902bd9E6A8D66D); 
    Team Teams = Team(TeamContract);

    //购买USDT合约地址
    address public UsdtContract = address(0xC6D80f381e2AAC4D718178632F64D1ac363271Cd);//测试
    // address public UsdtContract = address(0x55d398326f99059fF775485246999027B3197955);
    GlodContract usdttoken = GlodContract(UsdtContract);
    //代币合约地址
    address public Dmt4Contract = address(0xCe1a4bDAb9A4B4011bE8544C1DF07DD894e4C663);
    GlodContract Dmt4token = GlodContract(Dmt4Contract);
    //swap路由合约
    address public swapRouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    ISwapRouter swap = ISwapRouter(swapRouterAddress);

    
    

    //管理员
    address private owners_;
    modifier Owner {
        require(owners_ == msg.sender);
        _;
    }
    //四个档位
    uint[5] public Gear = [0,100 * 10**18,500 * 10**18,1000 * 10**18,5000 * 10**18];

    //用户当前档位
    mapping(address=>Gearing) public userGearing; 
    /**用户档位详情*/
    struct Gearing{
        uint256     gear;           //档位
        uint256     usdt;           //USDT数量
        uint256     glod;           //币数量 以及算力
        uint256     time;           //时间
    }

    //LP地址
    address public lpAddress = 0xa2aD3a5feA8A41364dc542EDdAee2D5183AEF824;
    //基金地址
    address public fundAddress = 0x738b8AEE644442ADb8D754476E79889Fd92c625A;



    //事件
    event buyEvent(address indexed owner,address indexed spender,uint256 value);
    constructor() {
    // constructor(address lpAddress_,address fundAddress_) {
        owners_ = msg.sender;
        // lpAddress = lpAddress_;
        // fundAddress = fundAddress_;
    }
    /**
    * 修改管理员
    */
    function setOwner(address owners) 
        public 
        Owner 
        returns (bool)
    {
        owners_ = owners;
        return true;
    }
    /**
    * 修改LP地址
    */
    function setLpAddress(address lpAddress_) 
        public 
        Owner 
        returns (bool)
        {
            lpAddress = lpAddress_;
            return true;
        }
    /**
    * 修改基金地址
    */
    function setFundAddress(address fundAddress_) 
        public 
        Owner 
        returns (bool)
        {
            fundAddress = fundAddress_;
            return true;
        }
    //管理员转移本合约代币
    function totransferFrom(address glodContract,address to,uint256 amount)
        public
        Owner
        returns(bool)
        {
            GlodContract Token = GlodContract(glodContract);
            return Token.transferFrom(address(this),to,amount);
        }

    //购买档位
    function buy(uint256 gear_,address superior_)
        public
        returns(bool)
        {
            require(userGearing[msg.sender].gear < gear_, "Patern:The current gear is greater than the one purchased this time");
            if(Teams.team(msg.sender) == address(0x00)){
                Teams.bindingWhite(msg.sender,superior_);//-----需要白名单
            }
            userGearing[msg.sender].gear = gear_; //更新档位
            userGearing[msg.sender].usdt = Gear[gear_]; //更新档位花费USDT
            userGearing[msg.sender].glod = Patern.UsdtToToken(Gear[gear_],Dmt4Contract);//更新算力
            userGearing[msg.sender].time = block.timestamp;//更新时间
            usdttoken.transferFrom(msg.sender,address(this),Gear[gear_]);
            usdttoken.transfer(lpAddress,Gear[gear_]*25/100);
            usdttoken.transfer(fundAddress,Gear[gear_]*5/100);
            usdttoken.approve(swapRouterAddress,Gear[gear_]*70/100);
            address[] memory paths = new address[](2);
            paths[0] = UsdtContract;
            paths[1] = Dmt4Contract; 
            uint256[] memory amounts = swap.swapExactTokensForTokens(Gear[gear_]*70/100,0,paths,address(this),block.timestamp+1800);
            // ls0 = amounts[0];//usdt数量 数组中第一个的数量
            uint256 thisdmt4 = amounts[1];//代币数量 数组中第二个的数量
            Dmt4token.transfer(lpAddress,thisdmt4*25/70);
            Dmt4token.toBurn(address(this),thisdmt4*45/70);//-----需要白名单

            return true;
        }

    


    /**
    * 返回管理员地址
    */
    function owner()
        public 
        view 
        returns(address)
    {
        return owners_;
    }
    /**
    * usdt兑换代币的数量
    */
    function UsdtToToken(uint256 amount_,address token_) 
        public 
        view 
        returns(uint256)
        {
            address[] memory paths = new address[](2);
            paths[0] = UsdtContract;
            paths[1] = token_;
            uint256[] memory amounts = swap.getAmountsOut(amount_,paths);
            return amounts[1];
        } 
    function _PoweRand(uint256 min_,uint256 poor_,uint256 i_) 
        internal 
        view 
        returns(uint256 PoweRand)
        {
            uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,i_)));
            uint256 rand = random % poor_;
            return (min_ + rand);
        }
    function onERC1155Received(address,address,uint256,uint256,bytes calldata) 
        external 
        pure 
        returns(bytes4)
        {
            return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
        }
}