/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface ISmartSwapRouter02 {
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
        
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


contract rigelScheduleAlarm is Context {
    IERC20 public rigelToken;
    ISmartSwapRouter02 public smartSwap;
    address payable public devWallet;
    address public owner;
    uint256 public fee;
    uint256 public orderCount;
    uint256 public totalFeeCollected;
    
    struct userData {
        uint256 _id;
        uint256 amountIn;
        uint256 time;
        address caller;
        address[] path;
    }
    
    mapping(address => mapping(uint256 => userData)) private Data;
    mapping(uint256 => bool) public orderCancelled;
    mapping(uint256 => bool) public orderFilled;
    mapping (address => bool) public permit;

    event markOrder(
        uint256 id,
        address indexed user,
        address indexed to,
        address swapFromToken,
        address swapToToken,
        uint256 amountToSwap
    );

    event Cancel(
        uint256 id,
        address indexed user,
        address swapFromToken,
        address swapToToken,
        uint256 amountIn,
        uint256 timestamp
    );

    event fulfilOrder(
        address indexed caller,
        address indexed to,
        address swapFromToken,
        address swapToToken,
        uint256 amountToSwap,
        uint256 time
    );

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor(address _rigelToken, address _routerContract, address dev, uint256 timeFee)  {
        rigelToken = IERC20(_rigelToken);
        smartSwap = ISmartSwapRouter02(_routerContract);
        fee = timeFee;
        devWallet = payable(dev);
        owner = _msgSender();
    }

    receive() external payable {}

    function grantAccess(address addr, bool status) external onlyOwner {
        permit[addr] = status;
    }

    function updateRigelFee(uint256 _newFee) external onlyOwner {
        fee = _newFee;
    }

    function changeRouterContract(address _newRouter) external onlyOwner {
        smartSwap = ISmartSwapRouter02(_newRouter);
    }

    function setOrderID(
        uint256 _orderID,
        address _swapFromToken,
        address _swapToToken,
        address _user, 
        uint256 _amountIn
        ) internal {
        userData storage st = Data[_user][_orderID];
        address[] memory path = new address[](2);
        path[0] = address(_swapFromToken);
        path[1] = _swapToToken;
        st._id = _orderID;
        st.amountIn = _amountIn;
        st.path = path;
        st.caller = _user;
        st.time = block.timestamp;
    }

    function checkAllowance(address swapFrom, address user, uint256 amount) internal view {
        uint256 allowToSpend = IERC20(swapFrom).allowance(user, address(this));
        uint256 allowForFee = rigelToken.allowance(user, address(this));
        require(allowForFee >= fee, "Approval Check Fail For fee");
        if (swapFrom != address(0)) {            
            require(allowToSpend >= amount, "Approval Check Fail before Swap");
        }
    }

    function swapExactTokens(
        uint256 _orderID,
        address[] calldata path,
        address _user, 
        uint256 _amountIn
        ) external {    
              
        if (_orderID > orderCount) {
            setOrderID(_orderID, path[0], path[1], _user, _amountIn );
            orderCount = orderCount + 1;
        }
        userData storage st = Data[_user][_orderID];
        require(permit[_msgSender()] == true, "Rigel's: Access denied");
        checkAllowance(path[0], _user, _amountIn);
        rigelToken.transferFrom(_user, devWallet, fee);
        totalFeeCollected = totalFeeCollected + fee;
        IERC20(path[0]).approve(address(smartSwap), _amountIn);
        uint256[] memory outputAmount = smartSwap.getAmountsOut(
            _amountIn,
            path
        );
        // update the time this trx occure.
        st.time = block.timestamp;
        require(IERC20(path[0]).transferFrom(_user, address(this), _amountIn));
        smartSwap.swapExactTokensForTokens(
            _amountIn,
            outputAmount[1],
            path,
            _user,
            block.timestamp + 1200
        );
        
        emit fulfilOrder(
            _msgSender(),
            _user,
            address(path[0]),
            path[1],
            _amountIn,
            block.timestamp
        );
    }

    function swapTokensForETH(
        uint256 _orderID,
        address[] calldata path,
        address _user, 
        uint256 _amountIn
        ) external {
        if (_orderID > orderCount) {
            setOrderID(_orderID, path[0], smartSwap.WETH(), _user, _amountIn );
            orderCount = orderCount + 1;
        }
        userData storage st = Data[_user][_orderID];
        require(permit[_msgSender()] == true, "Rigel's: Access denied");
        checkAllowance(address(0), _user, _amountIn);
        rigelToken.transferFrom(_user, devWallet, fee);
        totalFeeCollected = totalFeeCollected + fee;
        IERC20(path[0]).approve(address(smartSwap), _amountIn);
        uint256[] memory outputAmount = smartSwap.getAmountsOut(
            _amountIn,
            path
        );
        // update the time this trx occure.
        st.time = block.timestamp;
        require(IERC20(path[0]).transferFrom(_user, address(this), _amountIn));
        smartSwap.swapExactTokensForETH(
            _amountIn,
            outputAmount[1],
            path,
            _user,
            block.timestamp + 1200
        );
        
        emit fulfilOrder(
            _msgSender(),
            _user,
            address(path[0]),
            path[1],
            _amountIn,
            block.timestamp
        );
    }

    function setPeriodToSwapETHForTokens(
        address[] calldata path,
        uint256 _timeOf
        ) external payable{
        
        orderCount = orderCount + 1;
        userData storage _userData = Data[_msgSender()][orderCount];  
        _userData._id = orderCount;
        _userData.caller = _msgSender();
        _userData.amountIn = msg.value;
        _userData.path = [path[0], path[1]];
        _userData.time = block.timestamp;
        _userData.time = _timeOf;
        emit markOrder(
            _userData._id,
            _msgSender(),
            _msgSender(),
            path[0],
            path[1],
            msg.value
        );
    }

   function SwapETHForTokens(uint256 _id, address _user) external {
        require(permit[_msgSender()] == true, "Rigel's: Access denied");
        require(_id > 0 && _id <= orderCount, "Error: wrong id");
        require(!orderCancelled[_id], "Rigel: order already cancelled");
        userData memory _userData = Data[_user][_id]; 
        rigelToken.transferFrom(_user, devWallet, fee);
        totalFeeCollected = totalFeeCollected + fee;
        IERC20(_userData.path[1]).approve(address(smartSwap), _userData.amountIn);
        userData storage st = Data[_user][_id];
        uint256[] memory outputAmount = smartSwap.getAmountsOut(
            _userData.amountIn,
            _userData.path
        );
        // update the time this trx occure.
        st.time = block.timestamp;
        if(_userData.path[0] == smartSwap.WETH()) {
            smartSwap.swapExactETHForTokens{value: _userData.amountIn}(
                outputAmount[1],
                _userData.path,
                _user,
                block.timestamp + 1200
            );
        }
        emit fulfilOrder(
            _msgSender(),
            _user,
            _userData.path[0],
            _userData.path[1],
            _userData.amountIn,
            block.timestamp
        );
    }

    function withdrawToken(address _token, address _user, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(_user, _amount);
    }

    function withdrawETH(address _user, uint256 _amount) external onlyOwner {
        payable(_user).transfer(_amount);
    }

    function getUserData(address _user, uint256 _id) external view 
        returns(
        uint256 id,
        uint256 amountIn,
        uint256 time,
        address caller,
        address[] memory path) {
        userData memory _userData = Data[_user][_id];
        return(
        _userData._id,
        _userData.amountIn,
        _userData.time,
        _userData.caller,
        _userData.path
        );
    }
}