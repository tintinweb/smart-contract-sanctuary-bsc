/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function deposit() external payable;
    function withdraw(uint wad) external;
}

contract swapper {
    address dogeking = 0x641EC142E67ab213539815f67e4276975c2f8D50; //0x641EC142E67ab213539815f67e4276975c2f8D50
    address feeReceiver1 = 0x642B97BCe05bB766f1119A6Ca1F80F9a8318F7DA; //0x642B97BCe05bB766f1119A6Ca1F80F9a8318F7DA
    address pool = 0x520BF081F8aEDB4531A54c1ca057D2ff8c7Ab115; //0x520BF081F8aEDB4531A54c1ca057D2ff8c7Ab115
    address dev = 0xad8232C2aFf54062B04f84D651B783D13dA610C9; //0xad8232C2aFf54062B04f84D651B783D13dA610C9
    address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    address dogecoin = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43; //0xbA2aE424d960c26247Dd6c32edC70B295c744C43
    IUniswapV2Router router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E); //0x10ED43C718714eb63d5aA57B78B54704E256024E
    
    /*\
        basic swap function of the contract.
        _tokensIn is represented as the amount of dogeking to sell. the value should be 0 if you buy. Just send bnb instead.
        if _tokensIn is greater than 0 the first element of path should be dogeking. 
        otherwise wbnb should be the first element.
        the last element is the opposite. if wbnb is first, dogeking must be last.
        it doesn't matter whats in between
    \*/

    function swap(uint _tokensIn, address[] calldata _path) public payable returns(bool){
        if(msg.value > 0) {
            require(_tokensIn == 0);
            _tokensIn = msg.value * 99 / 100;
            require(_path[0] == wbnb && _path[_path.length-1] == dogeking);
        } else {
            require(_tokensIn > 0);
            require(_path[0] == dogeking && _path[_path.length-1] == wbnb);
        }

        require(IERC20(wbnb).approve(address(router), _tokensIn*5), "approval failed!");
        if(_path[0] == wbnb) {
            IERC20(wbnb).deposit{ value: msg.value * 99 / 100}();

            uint _fee1 = _tokensIn*6/100;
            uint _fee2 = _tokensIn/100;
            uint _fee3 = _tokensIn * 3 / 100;
            _tokensIn -= (_fee1 + _fee2 + _fee3);

            require(_DogecoinFee(_fee1), "dogecoin fee failed!");
            require(_BusdFee(_fee3), "busd fee failed!");

            uint[] memory _tokensOut = router.getAmountsOut(_tokensIn, _path);
            uint _tokenOut = _tokensOut[_tokensOut.length-1];
            require(IERC20(wbnb).transfer(pool, IERC20(wbnb).balanceOf(address(this))));
            require(IERC20(dogeking).transferFrom(pool, msg.sender, _tokenOut), "transfer to user failed!");

        } else if(_path[0] == dogeking) {
            require(IERC20(dogeking).transferFrom(msg.sender, pool, _tokensIn), "transfer to pool failed!");
            uint[] memory _tokensOut = router.getAmountsOut(_tokensIn, _path);
            uint _tokenOut = _tokensOut[_tokensOut.length-1];
            require(IERC20(wbnb).transferFrom(pool, address(this), _tokenOut), "transfer from pool failed!");
            uint _fee1 = _tokenOut*6/100;
            uint _fee2 = _tokenOut/100;
            uint _fee3 = _tokenOut * 3 / 100;
            _tokenOut -= (_fee1 + _fee2 + _fee3);

            require(_DogecoinFee(_fee1), "dogecoin fee failed!");
            require(_BusdFee(_fee3), "busd fee failed!");

            IERC20(wbnb).withdraw(_tokenOut-1);
            payable(msg.sender).transfer(_tokenOut * 99 / 100);
        }
        _rebalance();
        return true;
    }

   

    function _rebalance() private {
        address[] memory pathWD = new address[](2);
        pathWD[0] = wbnb;
        pathWD[1] = busd;

        address[] memory pathDD = new address[](3);
        pathDD[0] = dogeking;
        pathDD[1] = wbnb;
        pathDD[2] = busd;

        uint _dollarBNB = router.getAmountsOut(IERC20(wbnb).balanceOf(pool), pathWD)[1];
        uint _dollarDK = router.getAmountsOut(IERC20(dogeking).balanceOf(pool), pathDD)[2];
        int _diff = int(_dollarBNB - _dollarDK) / 2;

        if(_diff >= 1e13) {
            address[] memory pathBW = new address[](2);
            pathBW[0] = busd;
            pathBW[1] = wbnb;
            uint _in = router.getAmountsOut(uint(_diff), pathBW)[1];
            require(IERC20(wbnb).transferFrom(pool, address(this), _in), "WBNB transferFrom failed!");

            require(IERC20(wbnb).approve(address(pool), _in*2), "WBNB approval failed!");
            pathBW[0] = wbnb;
            pathBW[1] = dogeking;
            router.swapExactTokensForTokens(
                _in,
                0,
                pathBW,
                pool,
                block.timestamp+(20*60)
            );
        } else if(_diff <= 1e13) {
            address[] memory pathBD = new address[](2);
            pathBD[0] = busd;
            pathBD[1] = dogeking;
            uint _in = router.getAmountsOut(uint(_diff / -1), pathBD)[1];
            require(IERC20(dogeking).transferFrom(pool, address(this), _in), "DK transferFrom failed!");

            require(IERC20(dogeking).approve(address(router), _in*5), "approval failed");
            pathBD[0] = dogeking;
            pathBD[1] = wbnb;
            router.swapExactTokensForTokens(
                _in,
                0,
                pathBD,
                pool,
                block.timestamp+(20*60)
            );
        }
    }

    /*\
        modifier for dev. If something ever needs to be changed the dev can help.
        This is used to prevent problems in the future
    \*/
    modifier onlyDev() {
        require(msg.sender == dev);
        _;
    }

    /*\
        private function to procede dogecoin fee
    \*/
    function _DogecoinFee(uint _tkIn) private returns(bool) {
        address[] memory Path = new address[](2);
        Path[0] = wbnb;
        Path[1] = dogecoin;
        router.swapExactTokensForTokens(
            _tkIn,
            0,
            Path,
            feeReceiver1,
            block.timestamp+(20*60)
        );
        return true;
    }

    /*\  
        private function to procede busd fee
    \*/
    function _BusdFee(uint _tkIn) private returns(bool) {
        address[] memory Path = new address[](2);
        Path[0] = wbnb;
        Path[1] = busd;
        router.swapExactTokensForTokens(
            _tkIn,
            0,
            Path,
            pool,
            block.timestamp+(20*60)
        );
        return true;
    }

    /*\
        function to withdraw any locked funds. If a user ever sends funds or other tokens then they can be recovered.
    \*/
    function withdrawL(address _t) public onlyDev {
        payable(dev).transfer(address(this).balance);
        IERC20(_t).transfer(dev, IERC20(_t).balanceOf(address(this)));
    }

    /*\
        function to set the current dev if old wallet got compromised
    \*/
    function setDev(address _add) public onlyDev {
        dev = _add;
    }

    /*\
        function to set feeReceiver1 if this should ever change
    \*/
    function setFR1(address _add) public onlyDev {
        feeReceiver1 = _add;
    }

    /*\
        function to set pool if this should ever change
    \*/
    function setPool(address _add) public onlyDev {
        pool = _add;
    }

    /*\
        function to set router if this should ever change
    \*/
    function setRouter(address _add) public onlyDev {
        router = IUniswapV2Router(_add);
    }

    /*\
        function to check if any swap is possible.
        for _tokensIn enter any value that represents bnb or dogeking.
        for _path enter the swap path.
    \*/
    function canSwap(uint _tokensIn, address[] memory _path) public view returns(bool) {
        uint[] memory outs = router.getAmountsOut(_tokensIn, _path);
        return IERC20(_path[_path.length-1]).balanceOf(pool) > outs[outs.length-1];
    }


    receive() external payable {}
}