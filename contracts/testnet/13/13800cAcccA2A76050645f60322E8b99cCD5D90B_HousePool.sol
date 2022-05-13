// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IHousePool.sol";
import "./VRFHelper.sol";
import "./IERC20.sol";

contract HousePool is IHousePool, VRFHelper
{
    /*
        @dev shares are proportional to the amount of the liquidity pool an account is entitled to withdraw
    */
    mapping(address => mapping(address => uint256)) private _shares;
    mapping(address => uint256) private _shareTotals;

    /*
        @dev address zero used for ETH mapping indexes
    */
    address private constant ETH_INDEX = address(0);

    constructor()
    {

    }

    receive() external payable {}

    /*  
        @param VRF request ID

        @return requestor address
        @return bet token
        @return VRF responses
        @return bets [VRF response][Overlap bet][Wager, PayoutOdds, Lower, Upper, Range]
    */
    function getRoll(uint256 requestId) external view override returns(address, address, uint256[] memory, uint256[5][][] memory)
    {
        Roll memory roll = rolls[requestId];

        return (roll.requestor, roll.token, roll.responses, roll.bets);
    }

    /*
        @notice the returned uint256 is formatted like a 3 point floating number. For example, 4251 is equal to 4.251

        @param address of share owner
        @param token address of shares

        @return accounts ETH share balance
        @return ETH liquidity share price
    */
    function getETHShares(address account) external view returns (uint256, uint256)
    {
        return _getShares(account, ETH_INDEX);
    }

    /*
        @notice the returned uint256 is formatted like a 3 point floating number. For example, 4251 is equal to 4.251

        @param address of share owner
        @param token address of shares

        @return accounts token share balance
        @return token liquidity share price
    */
    function getTokenShares(address account, address token) external view returns (uint256, uint256) 
    {
        return _getShares(account, token);
    }

    /*
        @dev ERC20 tokens and ETH share the same mappings, use this address for ETH values

        @return address index used for ETH
    */
    function getETHIndex() external pure override returns (address)
    {
        return ETH_INDEX;
    }

    /*
        @notice the returned uint256 is formatted like a 2 point floating number. For example, 270 is equal to 2.70 or 2.7%

        @param amount wager is multiplied by
        @param lowest value random number can be and win (inclusive)
        @param highest value random number can be and win (inclusive)
        @param random number is between 1 and this parameter

        @return the house edge percentage
    */
    function getHouseEdge(uint256 payoutOdds, uint256 lower, uint256 upper, uint256 range) external pure returns (uint256)
    {
        return _getHouseEdge(payoutOdds, lower, upper, range);
    }

    /*
        @param VRF request ID
        @param VRF response index
        @param overlap bet index

        @return did the bet win
    */
    function isWinningBet(uint256 requestId, uint256 responseIndex, uint256 overlapIndex) external view override returns (bool)
    {
        return _isWinningBet(requestId, responseIndex, overlapIndex);
    }

    /*
        @return success
    */
    function addETHLiquidity() external override payable returns (bool)
    {
        _addLiquidity(msg.sender, ETH_INDEX, msg.value);

        return true;
    }

    /*
        @notice contract must be approved to spend at least amount specified in parameters

        @param contract address of ERC20 token to add
        @param amount of ERC20 tokens to add to the liquidity

        @return success
    */
    function addTokenLiquidity(address token, uint256 amount) external override returns (bool)
    {
        // Use addETHLiquidity() instead
        require(token != ETH_INDEX);

        _addLiquidity(msg.sender, token, amount);

        return true;
    }

    /*
        @notice to remove your principle and earnings, enter the principle

        @param number of shares to withdraw from liquidity

        @return success
    */
    function removeETHLiquidity(uint256 shareAmount) external override returns (bool)
    {
        _removeLiquidity(msg.sender, ETH_INDEX, shareAmount);

        return true;    
    }

    /*
        @notice to remove your principle and earnings, enter the principle

        @param contract address of ERC20 token to remove
        @param number of shares to withdraw from liquidity

        @return success
    */
    function removeTokenLiquidity(address token, uint256 shareAmount) external override returns (bool)
    {
        _removeLiquidity(msg.sender, token, shareAmount);

        return true;
    }

    /*
        @notice msg.value must be at least total wagered in parameters
        @notice PayoutOdds is formatted like a 2 point floating number. For example, 3500 is equal to 35.00 or 35x
        @notice Lower and Upper are both inclusive
        @notice use the Chainlink VRF docs when deciding VRF request parameters: https://docs.chain.link/docs/chainlink-vrf/

        @param bets [VRF response][Overlap bet][Wager, PayoutOdds, Lower, Upper, Range]
        @param keyHash corresponds to a particular oracle job which uses that key for generating the VRF proof
        @param subId is the ID of the VRF subscription. Must be funded with the minimum subscription balance required for the selected keyHash
        @param confirmations is how many blocks you'd like the oracle to wait before responding to the request
        @param gasLimit is how much gas you'd like to receive in your fulfillRandomWords callback

        @return VRF request ID
    */
    function requestETHRoll(uint256[5][][] memory bets, bytes32 keyHash, uint64 subId, uint16 confirmations, uint32 gasLimit) external override payable returns (uint256)
    {
        return _requestRoll(msg.sender, ETH_INDEX, msg.value, bets, keyHash, subId, confirmations, gasLimit);
    }

    /*
        @notice contract must be approved to spend at least amount wagered in parameters
        @notice PayoutOdds is formatted like a 2 point floating number. For example, 3500 is equal to 35.00 or 35x
        @notice Lower and Upper are both inclusive
        @notice use the Chainlink VRF docs when deciding VRF request parameters: https://docs.chain.link/docs/chainlink-vrf/

        @param contract address of token wagered
        @param bets [VRF response][Overlap bet][Wager, PayoutOdds, Lower, Upper, Range]
        @param keyHash corresponds to a particular oracle job which uses that key for generating the VRF proof
        @param subId is the ID of the VRF subscription. Must be funded with the minimum subscription balance required for the selected keyHash
        @param confirmations is how many blocks you'd like the oracle to wait before responding to the request
        @param gasLimit is how much gas you'd like to receive in your fulfillRandomWords callback

        @return VRF request ID
    */
    function requestTokenRoll(address token, uint256[5][][] memory bets, bytes32 keyHash, uint64 subId, uint16 confirmations, uint32 gasLimit) external override returns (uint256)
    {
        return _requestRoll(msg.sender, token, 0, bets, keyHash, subId, confirmations, gasLimit);
    }

    /*
        @notice transfers winning bets to the roll requestor address

        @param VRF request ID
    */
    function withdrawRoll(uint256 requestID) external override returns (uint256)
    {
        return _withdrawRoll(requestID);
    }

    /*
        @dev the returned uint256 is formatted like a 3 point floating number. For example, 4251 is equal to 4.251

        @param token contract

        @return account token shares
        @return tokens liquidity share price
    */
    function _getShares(address account, address token) private view returns(uint256, uint256)
    {
        return (_shares[token][account], _getSharePrice(token));
    }

    /*
        @dev the returned uint256 is formatted like a 3 point floating number. For example, 4251 is equal to 4.251

        @param token contract

        @return tokens liquidity share price
    */
    function _getSharePrice(address token) private view returns (uint256)
    {
        return (_getLiquidityBalance(token) * 1000) / _shareTotals[token];
    }

    /*
        @dev use ETH_INDEX in parameter to return ETH balance

        @param token contract

        @return amount of tokens or ETH in this contract
    */
    function _getLiquidityBalance(address token) private view returns (uint256)
    {
        if(token == ETH_INDEX)
        {
            // Return contract ETH balance
            return address(this).balance;
        }

        // Return contracts ERC20 token balance
        return IERC20(token).balanceOf(address(this));
    }

    /*
        @dev the returned uint256 is formatted like a 2 point floating number. For example, 270 is equal to 2.70 or 2.7%

        @param amount wager is multiplied by
        @param lowest value random number can be and win (inclusive)
        @param highest value random number can be and win (inclusive)
        @param random number is between 1 and this parameter

        @return the house edge percentage
    */
    function _getHouseEdge(uint256 payoutOdds, uint256 lower, uint256 upper, uint256 range) private pure returns (uint256)
    {
        // Upper bound must be greater than lower bound
        require(upper >= lower);

        uint256 winRange = (upper - lower) + 1;
        uint256 loseOdds = ((range - winRange) * 100) / winRange;

        // House edge = (Odds against Success – House Odds) x Probability of Success
        return ((loseOdds - payoutOdds) * ((winRange * 1000) / range)) / 10;
    }

    /*
        @param VRF request ID
        @param response index
        @param overlap index

        @return did bet win
    */
    function _isWinningBet(uint256 requestId, uint256 responseIndex, uint256 overlapIndex) private view returns (bool)
    {
        Roll memory roll = rolls[requestId];

        // Get random number from VRF response
        uint256 rolledNumber = (roll.responses[responseIndex] % roll.bets[responseIndex][overlapIndex][4]) + 1;

        // Check the random number is within the bets lower to upper range
        if(rolledNumber >= roll.bets[responseIndex][overlapIndex][2] && rolledNumber <= roll.bets[responseIndex][overlapIndex][3])
        {
            // Winner!
            return true;
        }

        // Loser :(
        return false;
    }

    /*
        @param address adding liquidity
        @param token contract being added
        @param amount of tokens added
    */
    function _addLiquidity(address from, address token, uint256 amount) private
    {
        require(amount > 0);

        if(token == ETH_INDEX)
        {
            emit AddETHLiquidity(from, amount);
        }
        else
        {
            // Transfer tokens from account to liquidity pool
            IERC20(token).transferFrom(from, address(this), amount);

            emit AddTokenLiquidity(from, token, amount);
        }

        // Set inital share price to 1:1 with token
        uint256 newShares = amount;

        // If shares exist, use liquidity pools share price
        if(_shareTotals[token] > 0)
        {
            // Share price has 3 decimal places
            newShares = (amount * 1000) / _getSharePrice(token);
        }

        // Add shares to account
        _shares[token][from] += newShares;
        // Add shares to share supply
        _shareTotals[token] += newShares;
    }

    /*
        @param address removing liquidity
        @param contract of token being removed
        @param amount of shares being removed
    */
    function _removeLiquidity(address from, address token, uint256 shareAmount) private
    {
        // Check account has enough shares to withdraw
        require(shareAmount <= _shares[token][from]);

        // Get contract balance of specified token
        uint256 contractBalance = _getLiquidityBalance(token);

        // Amount of tokens being withdrawn
        uint256 tokenAmount = (shareAmount * _getSharePrice(token)) / 1000;

        // Ensure contract has enough tokens to withdraw
        require(contractBalance > tokenAmount);

        // Remove shares from account
        _shares[token][from] -= shareAmount;
        // Remove shares from share supply
        _shareTotals[token] -= shareAmount;

        if(token == ETH_INDEX)
        {
            // Withdraw ETH from liquidity pool
            (bool os,) = payable(from).call{value: tokenAmount}("");
            require(os);

            emit RemoveETHLiquidity(from, tokenAmount);
        }
        else
        {
            // Withdraw tokens from liquidity pool
            IERC20(token).transfer(from, tokenAmount);

            emit RemoveTokenLiquidity(from, token, tokenAmount);
        }
    }

    /*
        @param requestor address
        @param bet token address
        @param expected amount of ETH to bet
        @param bets [VRF response][Overlap bet][Wager, PayoutOdds, Lower, Upper, Range]
        @param keyHash corresponds to a particular oracle job which uses that key for generating the VRF proof
        @param subId is the ID of the VRF subscription. Must be funded with the minimum subscription balance required for the selected keyHash
        @param confirmations is how many blocks you'd like the oracle to wait before responding to the request
        @param gasLimit is how much gas you'd like to receive in your fulfillRandomWords callback

        @return VRF request ID
    */
    function _requestRoll(address from, address token, uint256 amount, uint256[5][][] memory bets, bytes32 keyHash, uint64 subId, uint16 confirmations, uint32 gasLimit) private returns (uint256)
    {
        // Total amount of tokens or ETH wagered in this request
        uint256 totalBet = 0;

        // VRF responses
        for(uint256 i = 0; i < bets.length; i++)
        {
            // Overlapping bets
            for(uint256 a = 0; a < bets[i].length; a++)
            {
                // House edge must be greater than 1% (could change to 0.5% to give operators more room to take profits)
                // Could implement Kelly criterion similar to EdgeFund, instead of fixed house edge: https://www.edgefund.net/
                require(_getHouseEdge(bets[i][a][1], bets[i][a][2], bets[i][a][3], bets[i][a][4]) >= 100);

                // Add wager to requests total bet amount
                totalBet += bets[i][a][0];
            }
        }

        // Check total amount wagered in this requests is less than .01% of the tokens liquidity pool
        require(totalBet <= _getLiquidityBalance(token) / 10000);

        if(token != ETH_INDEX)
        {
            // Transfer wagers from requestor to house pool
            IERC20(token).transferFrom(from, address(this), totalBet);
        }
        else
        {
            // Check total wagered is equal to msg.value
            require(totalBet <= amount);
        }

        // Send VRF request using VRFHelper.sol
        return requestRandomWords(from, bets, token, keyHash, subId, confirmations, gasLimit);
    }

    /*
        @param VRF request ID
    */
    function _withdrawRoll(uint256 requestId) private returns (uint256)
    {
        Roll memory roll = rolls[requestId];

        // Check wagered tokens have already been withdrawn
        if(roll.withdrawn)
        {
            return 0;
        }     
        
        rolls[requestId].withdrawn = true;

        // Amount of tokens to send to roll requestor
        uint256 totalPayout = 0;

        // VRF responses
        for(uint256 i = 0; i < roll.bets.length; i++)
        {
            // Overlapping bets
            for(uint256 a = 0; a < roll.bets[i].length; a++)
            {
                // Check if bet was won
                if(_isWinningBet(requestId, i, a))
                {
                    // Add initial bet times payout odds to amount to be withdrawn
                    totalPayout += roll.bets[i][a][0] + ((roll.bets[i][a][0] * roll.bets[i][a][1]) / 100);
                }

                // The difference between the operators edge and the mandatory 1% house edge
                uint256 edgeDifference = _getHouseEdge(roll.bets[i][a][1], roll.bets[i][a][2], roll.bets[i][a][3], roll.bets[i][a][4]) - 100;

                // This is how operators are able to collect ETH/tokens for their games
                totalPayout += (roll.bets[i][a][0] * edgeDifference) / 10000;
            }
        }

        if(roll.token == ETH_INDEX)
        {
            // Send ETH to roll requestor
            (bool success,) = roll.requestor.call{value: totalPayout}("");
            require(success);

            emit WithdrawETH(roll.requestor, totalPayout);
        }
        else
        {
            // Send tokens to roll requestor
            IERC20(roll.token).transfer(roll.requestor, totalPayout);

            emit WithdrawToken(roll.requestor, roll.token, totalPayout);
        }

        return totalPayout;
    }
}