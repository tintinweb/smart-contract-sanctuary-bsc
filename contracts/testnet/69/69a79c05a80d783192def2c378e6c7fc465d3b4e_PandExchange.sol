/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
// PandExchange is a decentralized application allowing user to perform DCA in a fully decentralized way.
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
    uint256 slippageTolerance5Decimals;
}

contract PandExchange {
    /*
        PandExchange is a contract that allows you to exchange your tokens for another token using the DCA method.
        You can create a DCA Operation by calling the createDCAOperation function.
        You can cancel a DCA Operation by calling the cancelDCAOperation function.
        You can execute a DCA Operation by calling the executeDCAOperation function.
        As you cannot schedule functions executions in contracts, you have to call the executeDCAOperation function manually.
        To reward the users who call the executeDCAOperation function, a fee is taken from the amount of tokens to be exchanged,
        to compensate the gas fees.
        By doing so, this DApp can remain fully decentralized and trustless.
        There is a 0.5% fee of the amount of tokens to be exchanged, given to the contract owner to support the application development.
        All token swap are done using the DEX Router chosen by the user, at the DCA creation.
    */
    address private owner;
    bool private isPaused;

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
        uint256 fee5Decimals,
        address exchangeRouterAddress,
        uint256 slippageTolerance5Decimals
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
    event FeeUpdated(
        address indexed owner,
        uint256 indexed DCACreationTimestamp,
        uint256 oldFee,
        uint256 newFee
    );
    event SlippageTolerancegeUpdated(
        address indexed owner,
        uint256 indexed DCACreationTimestamp,
        uint256 oldSlippageTolerance,
        uint256 newSlippageTolerance
    );

    function addNewDCAToUser(
        UserDCAData memory _userDCAData,
        uint256 _amountOutMinFirstTransaction
    ) external payable notPaused returns (uint256) {
        //Add a DCA to the calling user and take the necessary funds to the contract
        //The funds can be retrieved at all time be cancelling the DCA
        //If one of the two address is address(0), its the chain native token

        uint256 timestamp = block.timestamp;
        uint256 totalAmountOverall = _userDCAData.totalOccurrences *
            _userDCAData.amountPerOccurrence;

        require(
            _userDCAData.periodDays *
                _userDCAData.totalOccurrences *
                _userDCAData.amountPerOccurrence >
                0,
            "Error: DCA Period, Total Occurrences and Amount Per Occurrence must be all greater than 0"
        );
        require(
            mapDCA[msg.sender][timestamp].periodDays == 0,
            "Error: Retry in a few seconds"
        );
        require(
            _userDCAData.fee5Decimals < 100_000,
            "Error: Fee must be inferior than 1, with 5 decimals"
        );
        require(
            _userDCAData.slippageTolerance5Decimals < 100_000,
            "Error: Slippage tolerance must be inferior than 1, with 5 decimals"
        );
        require(
            _userDCAData.currentOccurrence == 0,
            "Error: Current occurrence must be 0 at the start"
        );

        uint256 ownerFee = ((totalAmountOverall * 100_000) * 500) /
            10_000_000_000;

        _userDCAData.tokenInLockedAmount = totalAmountOverall - ownerFee;

        _userDCAData.amountPerOccurrence =
            _userDCAData.tokenInLockedAmount /
            _userDCAData.totalOccurrences;

        mapDCA[msg.sender][timestamp] = _userDCAData;

        emit AddedNewDCA(
            timestamp,
            msg.sender,
            _userDCAData.totalOccurrences,
            _userDCAData.periodDays,
            _userDCAData.tokenInLockedAmount,
            _userDCAData.tokenIn,
            _userDCAData.tokenOut,
            _userDCAData.fee5Decimals,
            _userDCAData.exchangeRouterAddress,
            _userDCAData.slippageTolerance5Decimals
        );

        if (_userDCAData.tokenIn != address(0)) {
            //Require the user to approve the transfer beforehand
            bool success = IERC20(_userDCAData.tokenIn).transferFrom(
                msg.sender,
                address(this),
                totalAmountOverall
            );
            require(success, "Error: TokenIn TransferFrom failed");
        } else {
            require(
                msg.value == totalAmountOverall,
                "Error: Wrong amount of native token sent"
            );
        }

        //The first occurrence is executed immediately
        executeSingleUserDCA(
            msg.sender,
            timestamp,
            _amountOutMinFirstTransaction
        );

        //Send the owner fee, a one time fee at the creation of the DCA
        sendFee(owner, _userDCAData.tokenIn, ownerFee);

        return timestamp;
    }

    function deleteUserDCA(uint256 _startDate) external {
        /*Delete a DCA to free the storage and transfer back to the user the remaining amount of token IN
            address(0) as the IN our OUT token mean that it is native token
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
            require(success, "Native token Transfer failed while deleting DCA.");
        }
    }

    function executeSingleUserDCA(
        address _userAddress,
        uint256 _DCAStartDate,
        uint256 _amountOutMin
    ) public notPaused {
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
             - Modify the userDCAData state to reflect the operation (need to do it 1st to avoid re-entrency attacks)
                - Increment the number of occurrence
                - Modify the lockedAmount of each token
             - Swap the defined amount of tokens, minus the fee, with the swap() function 
             - Send the fee to the caller of the function
             - Send the fee to the address that executed this function
        */

        UserDCAData memory userDCA = mapDCA[_userAddress][_DCAStartDate];

        require(userDCA.periodDays > 0, "Error: This DCA does not exist");
        require(
            userDCA.totalOccurrences > userDCA.currentOccurrence,
            "Error: DCA has already been completed, the user has to retrieve its tokens"
        );
        require(
            block.timestamp >=
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

        bool isLastOccurrence = userDCA.totalOccurrences ==
            userDCA.currentOccurrence;

        uint256 tradeAmount = userDCA.amountPerOccurrence;

        if (isLastOccurrence) {
            tradeAmount = userDCA.tokenInLockedAmount;
            mapDCA[_userAddress][_DCAStartDate].tokenInLockedAmount = 0;
        } else {
            mapDCA[_userAddress][_DCAStartDate].tokenInLockedAmount =
                userDCA.tokenInLockedAmount -
                userDCA.amountPerOccurrence;
        }

        uint256 feeCaller = 0;
        //If the caller is not the user, he will get a fee to compensate for the gas fees
        //The fee is set by the user when he created the DCA
        if (msg.sender != _userAddress) {
            feeCaller =
                ((tradeAmount * 100_000) * userDCA.fee5Decimals) /
                10_000_000_000;
        }

        //The amount of token to swap is the amount per occurrence minus the fee
        uint256 amountWithoutFees = tradeAmount - feeCaller;

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
            _amountOutMin,
            userDCA.tokenIn,
            userDCA.tokenOut,
            tradeAmount,
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
            _amountOutMin,
            _userAddress,
            userDCA.exchangeRouterAddress
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
            The called Router function depends on the nature of _tokenIn and _tokenOut, if one of them is native token or not
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
        //Case 2: _tokenIn is native token
        else if (_tokenIn == address(0)) {
            IRouter02(_exchangeRouterAddress)
                .swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: _amountIn
            }(_amountOutMin, _path, _userAddress, block.timestamp);
        }
        //Case 3: _tokenOut is native token
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
            require(success, "Native token Transfer failed while sending fee.");
        }
    }

    function modifyDCAFee(uint256 _newFee5Decimals, uint256 _DCAStartDate)
        public
        notPaused
    {
        /*
            Allow user to change the fee for its DCA
        */
        require(
            _newFee5Decimals < 100_000,
            "Error: Fee must be inferior than 1, with 5 decimals"
        );
        emit FeeUpdated(
            msg.sender,
            _DCAStartDate,
            mapDCA[msg.sender][_DCAStartDate].fee5Decimals,
            _newFee5Decimals
        );
        mapDCA[msg.sender][_DCAStartDate].fee5Decimals = _newFee5Decimals;
    }

    function modifySlippageTolerance(uint256 _DCAStartDate, uint256 _newSlippage)
        public
        notPaused
    {
        /*
            Allow user to change the slippage tolerance for its DCA
        */
        require(
            _newSlippage < 100_000,
            "Error: Slippage must be inferior than 1, with 5 decimals"
        );
        emit SlippageTolerancegeUpdated(
            msg.sender,
            _DCAStartDate,
            mapDCA[msg.sender][_DCAStartDate].slippageTolerance5Decimals,
            _newSlippage
        );
        mapDCA[msg.sender][_DCAStartDate].slippageTolerance5Decimals = _newSlippage;
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