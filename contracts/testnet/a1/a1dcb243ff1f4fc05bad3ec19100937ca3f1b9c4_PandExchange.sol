/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
// PandExchange is a decentralized application allowing user to perform DCA in a fully decentralized way.
// The application is built on top of the Binance Smart Chain and uses an external swap DApp to perform the swaps.
// The application is built by the PandExchange team.
// For more information, please visit pand.exchange
// Contact us at:
// Telegram: https://t.me/pandexchange
// Twitter: https://twitter.com/pandexchange

pragma solidity 0.8.16;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

//Generic interface for the swap router V1
interface IRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

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

//Generic interface for the swap router V2
interface IRouter02 is IRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

//Data structure to store the user's DCA data
struct UserDCAData {
    uint256 periodDays;
    uint256 totalOccurrences;
    uint256 currentOccurrence;
    uint256 amountPerOccurrence;
    address tokenIn;
    address tokenOut;
    uint256 tokenInLockedAmount;
    address[] swapPath;
    uint256 fee5Decimals;
    address exchangeRouterAddress;
}

contract PandExchange {
    address private owner;
    bool private isPaused;

    /*
        address of the pancakeswap v2 router : 0x10ED43C718714eb63d5aA57B78B54704E256024E
        address of the pancakeswap v2 factory : 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
        address of the pancakeswap v2 router ON TESTNET : 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        address of the pancakeswap v2 factory ON TESTNET : 0x6725F303b657a9451d8BA641348b6761A6CC7a17
        Zero address: 0x0000000000000000000000000000000000000000
        ERC20 token: 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
        WBNBTESTNET = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        BNB to ERC20 path: ["0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd", "0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee"]
    */

    constructor() {
        owner = msg.sender;
        isPaused = false;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Error: Require to be the contract's owner"
        );
        _;
    }

    modifier notPaused() {
        require(!isPaused, "Error: Contract is paused");
        _;
    }

    mapping(address => mapping(uint256 => UserDCAData)) public mapDCA;

    event AddedNewDCA(
        uint256 indexed DCACreationTimestamp,
        address indexed userAddress,
        uint256 totalOccurrence,
        uint256 period,
        uint256 amountPerOccurrence,
        address tokenIn,
        address tokenOut,
        uint256 fee5Decimals
    );
    event OccurrenceExecuted(
        uint256 indexed DCACreationTimestamp,
        address indexed userAddress,
        uint256 totalOccurrence,
        uint256 currentOccurrence,
        uint256 nextOccurrenceTimestamp,
        uint256 estimatedMinimumAmountOut,
        address tokenIn,
        address tokenOut,
        uint256 tokenInAmount,
        uint256 fee5Decimals
    );
    event DeletedDCA(
        uint256 indexed DCACreationTimestamp,
        address indexed userAddress
    );
    event NewOwner(address indexed oldOwner, address indexed newOwner);

    function addNewDCAToUser(
        uint256 _period,
        uint256 _totalOccurrences,
        uint256 _amountPerOccurrence,
        address _tokenIn,
        address _tokenOut,
        uint256 _fee5Decimals,
        address[] memory _path,
        address _exchangeRouterAddress
    ) external payable notPaused returns (uint256) {
        //Add a DCA to the calling user and take the necessary funds to the contract
        //The funds can be retrieved at all time be cancelling the DCA
        //If one of the two address is address(0), its the chain native token

        uint256 timestamp = block.timestamp;

        require(
            _period * _totalOccurrences * _amountPerOccurrence > 0,
            "Error: DCA Period, Total Occurrences and Amount Per Occurrence must be all greater than 0"
        );
        require(
            mapDCA[msg.sender][timestamp].periodDays == 0,
            "Error: Retry in a few seconds"
        );
        require(
            _fee5Decimals < 100000,
            "Error: Fee must be inferior than 1, with 5 decimals"
        );

        uint256 ownerFee = ((_totalOccurrences *
            _amountPerOccurrence *
            100_000) * 500) / 10_000_000_000;

        _amountPerOccurrence =
            _amountPerOccurrence -
            ownerFee /
            _totalOccurrences;

        mapDCA[msg.sender][timestamp] = UserDCAData(
            _period,
            _totalOccurrences,
            0,
            _amountPerOccurrence,
            _tokenIn,
            _tokenOut,
            _totalOccurrences * _amountPerOccurrence,
            _path,
            _fee5Decimals,
            _exchangeRouterAddress
        );

        emit AddedNewDCA(
            timestamp,
            msg.sender,
            _totalOccurrences,
            _period,
            _amountPerOccurrence,
            _tokenIn,
            _tokenOut,
            _fee5Decimals
        );
        
        if (_tokenIn != address(0)) {
            //Require the user to approve the transfer beforehand
            bool success = IERC20(_tokenIn).transferFrom(
                msg.sender,
                address(this),
                _totalOccurrences * _amountPerOccurrence
            );
            require(success, "Error: TokenIn TransferFrom failed");
        } else {
            require(
                msg.value >= _totalOccurrences * _amountPerOccurrence,
                "Error: You did not sent enough BNB"
            );
        }

        //The first occurrence is executed immediately
        executeSingleUserDCA(msg.sender, timestamp);

        //Send the owner fee, a one time fee at the creation of the DCA
        sendFee(owner, _tokenIn, ownerFee);

        return timestamp;
    }

    function deleteUserDCA(uint256 _startDate) external {
        /*Delete a DCA to free the storage and transfer back to the user the remaining amount of token IN
            address(0) as the IN our OUT token mean that it is BNB
        */

        UserDCAData memory userDCA = mapDCA[msg.sender][_startDate];
        require(userDCA.periodDays > 0, "Error: This DCA does not exist");

        delete mapDCA[msg.sender][_startDate];
        emit DeletedDCA(_startDate, msg.sender);

        bool success = false;
        if (userDCA.tokenIn != address(0)) {
            success = IERC20(userDCA.tokenIn).transfer(
                msg.sender,
                userDCA.tokenInLockedAmount
            );
            require(success, "ERC20 Transfer failed while deleting DCA.");
        } else {
            (success, ) = msg.sender.call{value: userDCA.tokenInLockedAmount}(
                ""
            );
            require(success, "BNB Transfer failed while deleting DCA.");
        }
    }

    function executeSingleUserDCA(address _userAddress, uint256 _DCAStartDate)
        public
        notPaused
    {
        /*  Execute a single occurrence of a single DCA for the user
            Find the right one by the user address and startDate value, which is unique for each DCA of a specific user
            It implies that we must know this exact value, which is done by listening to the AddedNewDCA event
            A contract that created a DCA can also get this as a return value of the addNewDCAToUser() function
            This function reward the caller with a percentage of the input token traded in an occurrence, to compensate for the gas fees
            Steps :
             - Security checks
               - The DCA must exist
               - The current date must be around startDate + period * currentOccurrence - margin 
               - The currentOccurrence number should be lower than the totalOccurrence (i.e. not completed)
             - Modify the userDCAData state to reflect the operation (need to do it 1st to avoir re-entrency attacks)
                - Increment the number of occurrence
                - Modify the lockedAmount of each token
             - Swap the defined amount of tokens, minus the fee, with the swap() function 
             - Send the fee to the caller of the function
             - Send the fee to the address that executed this function
             TODO: 
        */

        UserDCAData memory userDCA = mapDCA[_userAddress][_DCAStartDate];

        require(userDCA.periodDays > 0, "Error: This DCA does not exist");
        require(
            userDCA.totalOccurrences > userDCA.currentOccurrence,
            "Error: DCA has already been completed, the user has to retrieve its tokens"
        );
        require(
            block.timestamp >
                _DCAStartDate +
                    userDCA.periodDays *
                    1 days *
                    userDCA.currentOccurrence -
                    1800,
            "Error: Too soon to execute this DCA"
        );

        mapDCA[_userAddress][_DCAStartDate].currentOccurrence =
            userDCA.currentOccurrence +
            1;
        mapDCA[_userAddress][_DCAStartDate].tokenInLockedAmount =
            userDCA.tokenInLockedAmount -
            userDCA.amountPerOccurrence;

        uint256 feeCaller = 0;
        //If the caller is not the user, he will get a fee to compensate for the gas fees
        //The fee is set by the user when he created the DCA
        if (msg.sender != _userAddress) {
            feeCaller =
                ((userDCA.amountPerOccurrence * 100_000) *
                    userDCA.fee5Decimals) /
                10_000_000_000;
        }

        //The amount of token to swap is the amount per occurrence minus the fee
        uint256 amountWithoutFees = userDCA.amountPerOccurrence - feeCaller;

        //Get the estimated amount of token out from the swap, needed for the swap and for the event OccurrenceExecuted
        address exchangeRouterAddress = userDCA.exchangeRouterAddress;
        uint256 estimatedMinimumAmountOut = IRouter02(exchangeRouterAddress)
            .getAmountsOut(amountWithoutFees, userDCA.swapPath)[
                userDCA.swapPath.length - 1
            ];

        //Set the timestamp of the next occurrence. 0 if it is the last one (i.e. currentOccurrence == totalOccurrences)
        uint256 nextOccurrenceTimestamp = 0;
        if (userDCA.totalOccurrences > userDCA.currentOccurrence + 1) {
            nextOccurrenceTimestamp =
                block.timestamp +
                userDCA.periodDays *
                1 days;
        }
        emit OccurrenceExecuted(
            _DCAStartDate,
            _userAddress,
            userDCA.totalOccurrences,
            userDCA.currentOccurrence + 1,
            nextOccurrenceTimestamp,
            estimatedMinimumAmountOut,
            userDCA.tokenIn,
            userDCA.tokenOut,
            userDCA.amountPerOccurrence,
            userDCA.fee5Decimals
        );

        //Send the fee to the caller of the function, if any (i.e. if the caller is not the user)
        if (feeCaller > 0) {
            sendFee(msg.sender, userDCA.tokenIn, feeCaller);
        }

        //Swap the amount of token minus the fee
        //Out token is directly sent to the user
        swap(
            userDCA.tokenIn,
            userDCA.tokenOut,
            userDCA.swapPath,
            amountWithoutFees,
            estimatedMinimumAmountOut,
            _userAddress,
            exchangeRouterAddress
        );
    }

    function swap(
        address _tokenIn,
        address _tokenOut,
        address[] memory _path,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _userAddress,
        address _exchangeRouterAddress
    ) private {
        /*
            Swap _tokenIn for _tokenOut using the provided RouterV2 contract
            If _tokenIn is an ERC20 it first gives _amountIn allowance to the router to do the swap
            Then it calls the appropriate function for the swap
            The called Router function depends on the nature of _tokenIn and _tokenOut, if one of them is BNB or not
        */

        //Case 1: Both tokens are ERC20 tokens
        if (_tokenIn != address(0) && _tokenOut != address(0)) {
            bool success = IERC20(_tokenIn).approve(
                _exchangeRouterAddress,
                _amountIn
            );
            require(success, "ERC20 Transfer failed while approving swap.");
            IRouter02(_exchangeRouterAddress)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    _amountIn,
                    _amountOutMin,
                    _path,
                    _userAddress,
                    block.timestamp
                );
        }
        //Case 2: _tokenIn is BNB
        else if (_tokenIn == address(0)) {
            IRouter02(_exchangeRouterAddress)
                .swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: _amountIn
            }(_amountOutMin, _path, _userAddress, block.timestamp);
        }
        //Case 3: _tokenOut is BNB
        else if (_tokenOut == address(0)) {
            bool success = IERC20(_tokenIn).approve(
                _exchangeRouterAddress,
                _amountIn
            );
            require(success, "ERC20 Transfer failed while approving swap.");
            IRouter02(_exchangeRouterAddress)
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    _amountIn,
                    _amountOutMin,
                    _path,
                    _userAddress,
                    block.timestamp
                );
        }
    }

    function sendFee(
        address _recipient,
        address _tokenFee,
        uint256 _feeAmount
    ) private {
        require(_recipient != address(0), "Error: Invalid recipient address");
        bool success = false;
        if (_tokenFee != address(0)) {
            success = IERC20(_tokenFee).transfer(_recipient, _feeAmount);
            require(success, "ERC20 Transfer failed while sending fee.");
        } else {
            (success, ) = _recipient.call{value: _feeAmount}("");
            require(success, "BNB Transfer failed while sending fee.");
        }
    }

    function modifyDCAFee(uint256 _newFee5Decimals, uint256 _DCAStartDate)
        public
    {
        /*
            Allow user to change the fee for its DCA
        */
        require(
            _newFee5Decimals < 100000,
            "Error: Fee must be inferior than 1, with 5 decimals"
        );
        mapDCA[msg.sender][_DCAStartDate].fee5Decimals = _newFee5Decimals;
    }

    //Functions to get/set contract global variables

    function pause() public onlyOwner {
        isPaused = true;
    }

    function unPause() public onlyOwner {
        isPaused = false;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function setOwner(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "Error: New owner cannot be 0 address"
        );
        address oldOwner = owner;
        owner = _newOwner;
        emit NewOwner(oldOwner, _newOwner);
    }
}