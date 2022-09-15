// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import './interfaces/IERC20ConversionProxy.sol';
import './interfaces/IEthConversionProxy.sol';
import './BatchNoConversionPayments.sol';

/**
 * @title BatchConversionPayments
 * @notice This contract makes multiple conversion payments with references, in one transaction:
 *          - on:
 *              - ERC20 tokens: using Erc20ConversionProxy and ERC20FeeProxy
 *              - Native tokens: (e.g. ETH) using EthConversionProxy and EthereumFeeProxy
 *          - to: multiple addresses
 *          - fees: conversion proxy fees and additional batch conversion fees are paid to the same address.
 *         batchRouter is the main function to batch all kinds of payments at once.
 *         If one transaction of the batch fails, all transactions are reverted.
 * @dev Note that fees have 4 decimals (instead of 3 in a previous version)
 *      batchRouter is the main function, but other batch payment functions are "public" in order to do
 *      gas optimization in some cases.
 */
contract BatchConversionPayments is BatchNoConversionPayments {
  using SafeERC20 for IERC20;

  IERC20ConversionProxy public paymentErc20ConversionProxy;
  IEthConversionProxy public paymentEthConversionProxy;

  uint256 public batchConversionFee;

  /**
   * @dev All the information of a request, except the feeAddress
   *   _recipient Recipient address of the payment
   *   _requestAmount Request amount in fiat
   *   _path Conversion path
   *   _paymentReference Unique reference of the payment
   *   _feeAmount The fee amount denominated in the first currency of `_path`
   *   _maxToSpend Maximum amount the payer wants to spend, denominated in the last currency of `_path`:
   *               it includes fee proxy but NOT the batchConversionFee
   *   _maxRateTimespan Max acceptable times span for conversion rates, ignored if zero
   */
  struct ConversionDetail {
    address recipient;
    uint256 requestAmount;
    address[] path;
    bytes paymentReference;
    uint256 feeAmount;
    uint256 maxToSpend;
    uint256 maxRateTimespan;
  }

  /**
   * @dev BatchNoConversionPayments contract input structure.
   */
  struct CryptoDetails {
    address[] tokenAddresses;
    address[] recipients;
    uint256[] amounts;
    bytes[] paymentReferences;
    uint256[] feeAmounts;
  }

  /**
   * @dev Used by the batchRouter to handle information for heterogeneous batches, grouped by payment network.
   *  - paymentNetworkId: from 0 to 4, cf. `batchRouter()` method.
   *  - conversionDetails all the data required for conversion requests to be paid, for paymentNetworkId = 0 or 4
   *  - cryptoDetails all the data required to pay requests without conversion, for paymentNetworkId = 1, 2, or 3
   */
  struct MetaDetail {
    uint256 paymentNetworkId;
    ConversionDetail[] conversionDetails;
    CryptoDetails cryptoDetails;
  }

  /**
   * @param _paymentErc20Proxy The ERC20 payment proxy address to use.
   * @param _paymentEthProxy The ETH payment proxy address to use.
   * @param _paymentErc20ConversionProxy The ERC20 Conversion payment proxy address to use.
   * @param _paymentEthConversionFeeProxy The ETH Conversion payment proxy address to use.
   * @param _owner Owner of the contract.
   */
  constructor(
    address _paymentErc20Proxy,
    address _paymentEthProxy,
    address _paymentErc20ConversionProxy,
    address _paymentEthConversionFeeProxy,
    address _owner
  ) BatchNoConversionPayments(_paymentErc20Proxy, _paymentEthProxy, _owner) {
    paymentErc20ConversionProxy = IERC20ConversionProxy(_paymentErc20ConversionProxy);
    paymentEthConversionProxy = IEthConversionProxy(_paymentEthConversionFeeProxy);
    batchConversionFee = 0;
  }

  /**
   * @notice Batch payments on different payment networks at once.
   * @param metaDetails contains paymentNetworkId, conversionDetails, and cryptoDetails
   * - batchMultiERC20ConversionPayments, paymentNetworkId=0
   * - batchERC20Payments, paymentNetworkId=1
   * - batchMultiERC20Payments, paymentNetworkId=2
   * - batchEthPayments, paymentNetworkId=3
   * - batchEthConversionPayments, paymentNetworkId=4
   * If metaDetails use paymentNetworkId = 4, it must be at the end of the list, or the transaction can be reverted
   * @param _feeAddress The address where fees should be paid
   * @dev batchRouter only reduces gas consumption when using more than a single payment network.
   *      For single payment network payments, it is more efficient to use the suited batch function.
   */
  function batchRouter(MetaDetail[] calldata metaDetails, address _feeAddress) external payable {
    require(metaDetails.length < 6, 'more than 5 metaDetails');
    for (uint256 i = 0; i < metaDetails.length; i++) {
      MetaDetail calldata metaConversionDetail = metaDetails[i];
      if (metaConversionDetail.paymentNetworkId == 0) {
        batchMultiERC20ConversionPayments(metaConversionDetail.conversionDetails, _feeAddress);
      } else if (metaConversionDetail.paymentNetworkId == 1) {
        batchERC20Payments(
          metaConversionDetail.cryptoDetails.tokenAddresses[0],
          metaConversionDetail.cryptoDetails.recipients,
          metaConversionDetail.cryptoDetails.amounts,
          metaConversionDetail.cryptoDetails.paymentReferences,
          metaConversionDetail.cryptoDetails.feeAmounts,
          _feeAddress
        );
      } else if (metaConversionDetail.paymentNetworkId == 2) {
        batchMultiERC20Payments(
          metaConversionDetail.cryptoDetails.tokenAddresses,
          metaConversionDetail.cryptoDetails.recipients,
          metaConversionDetail.cryptoDetails.amounts,
          metaConversionDetail.cryptoDetails.paymentReferences,
          metaConversionDetail.cryptoDetails.feeAmounts,
          _feeAddress
        );
      } else if (metaConversionDetail.paymentNetworkId == 3) {
        if (metaDetails[metaDetails.length - 1].paymentNetworkId == 4) {
          // Set to false only if batchEthConversionPayments is called after this function
          transferBackRemainingEth = false;
        }
        batchEthPayments(
          metaConversionDetail.cryptoDetails.recipients,
          metaConversionDetail.cryptoDetails.amounts,
          metaConversionDetail.cryptoDetails.paymentReferences,
          metaConversionDetail.cryptoDetails.feeAmounts,
          payable(_feeAddress)
        );
        if (metaDetails[metaDetails.length - 1].paymentNetworkId == 4) {
          transferBackRemainingEth = true;
        }
      } else if (metaConversionDetail.paymentNetworkId == 4) {
        batchEthConversionPayments(metaConversionDetail.conversionDetails, payable(_feeAddress));
      } else {
        revert('wrong paymentNetworkId');
      }
    }
  }

  /**
   * @notice Send a batch of ERC20 payments with amounts based on a request
   * currency (e.g. fiat), with fees and paymentReferences to multiple accounts, with multiple tokens.
   * @param conversionDetails list of requestInfo, each one containing all the information of a request
   * @param _feeAddress The fee recipient
   */
  function batchMultiERC20ConversionPayments(
    ConversionDetail[] calldata conversionDetails,
    address _feeAddress
  ) public {
    // a list of unique tokens, with the sum of maxToSpend by token
    Token[] memory uTokens = new Token[](conversionDetails.length);
    for (uint256 i = 0; i < conversionDetails.length; i++) {
      for (uint256 k = 0; k < conversionDetails.length; k++) {
        // If the token is already in the existing uTokens list
        if (
          uTokens[k].tokenAddress == conversionDetails[i].path[conversionDetails[i].path.length - 1]
        ) {
          uTokens[k].amountAndFee += conversionDetails[i].maxToSpend;
          break;
        }
        // If the token is not in the list (amountAndFee = 0)
        else if (uTokens[k].amountAndFee == 0 && (conversionDetails[i].maxToSpend) > 0) {
          uTokens[k].tokenAddress = conversionDetails[i].path[conversionDetails[i].path.length - 1];
          // amountAndFee is used to store _maxToSpend, useful to send enough tokens to this contract
          uTokens[k].amountAndFee = conversionDetails[i].maxToSpend;
          break;
        }
      }
    }

    IERC20 requestedToken;
    // For each token: check allowance, transfer funds on the contract and approve the paymentProxy to spend if needed
    for (uint256 k = 0; k < uTokens.length && uTokens[k].amountAndFee > 0; k++) {
      requestedToken = IERC20(uTokens[k].tokenAddress);
      uTokens[k].batchFeeAmount = (uTokens[k].amountAndFee * batchConversionFee) / tenThousand;
      // Check proxy's allowance from user, and user's funds to pay approximated amounts.
      require(
        requestedToken.allowance(msg.sender, address(this)) >= uTokens[k].amountAndFee,
        'Insufficient allowance for batch to pay'
      );
      require(
        requestedToken.balanceOf(msg.sender) >= uTokens[k].amountAndFee + uTokens[k].batchFeeAmount,
        'not enough funds, including fees'
      );

      // Transfer the amount and fee required for the token on the batch conversion contract
      require(
        safeTransferFrom(uTokens[k].tokenAddress, address(this), uTokens[k].amountAndFee),
        'payment transferFrom() failed'
      );

      // Batch contract approves Erc20ConversionProxy to spend the token
      if (
        requestedToken.allowance(address(this), address(paymentErc20ConversionProxy)) <
        uTokens[k].amountAndFee
      ) {
        approvePaymentProxyToSpend(uTokens[k].tokenAddress, address(paymentErc20ConversionProxy));
      }
    }

    // Batch pays the requests using Erc20ConversionFeeProxy
    for (uint256 i = 0; i < conversionDetails.length; i++) {
      ConversionDetail memory rI = conversionDetails[i];
      paymentErc20ConversionProxy.transferFromWithReferenceAndFee(
        rI.recipient,
        rI.requestAmount,
        rI.path,
        rI.paymentReference,
        rI.feeAmount,
        _feeAddress,
        rI.maxToSpend,
        rI.maxRateTimespan
      );
    }

    // Batch sends back to the payer the tokens not spent and pays the batch fee
    for (uint256 k = 0; k < uTokens.length && uTokens[k].amountAndFee > 0; k++) {
      requestedToken = IERC20(uTokens[k].tokenAddress);

      // Batch sends back to the payer the tokens not spent = excessAmount
      // excessAmount = maxToSpend - reallySpent, which is equal to the remaining tokens on the contract
      uint256 excessAmount = requestedToken.balanceOf(address(this));
      if (excessAmount > 0) {
        requestedToken.safeTransfer(msg.sender, excessAmount);
      }

      // Payer pays the exact batch fees amount
      require(
        safeTransferFrom(
          uTokens[k].tokenAddress,
          _feeAddress,
          ((uTokens[k].amountAndFee - excessAmount) * batchConversionFee) / tenThousand
        ),
        'batch fee transferFrom() failed'
      );
    }
  }

  /**
   * @notice Send a batch of ETH conversion payments with fees and paymentReferences to multiple accounts.
   *         If one payment fails, the whole batch is reverted.
   * @param conversionDetails List of requestInfos, each one containing all the information of a request.
   *                     _maxToSpend is not used in this function.
   * @param _feeAddress The fee recipient.
   * @dev It uses EthereumConversionProxy to pay an invoice and fees.
   *      Please:
   *        Note that if there is not enough ether attached to the function call,
   *        the following error is thrown: "revert paymentProxy transferExactEthWithReferenceAndFee failed"
   *        This choice reduces the gas significantly, by delegating the whole conversion to the payment proxy.
   */
  function batchEthConversionPayments(
    ConversionDetail[] calldata conversionDetails,
    address payable _feeAddress
  ) public payable {
    uint256 contractBalance = address(this).balance;
    payerAuthorized = true;

    // Batch contract pays the requests through EthConversionProxy
    for (uint256 i = 0; i < conversionDetails.length; i++) {
      paymentEthConversionProxy.transferWithReferenceAndFee{value: address(this).balance}(
        payable(conversionDetails[i].recipient),
        conversionDetails[i].requestAmount,
        conversionDetails[i].path,
        conversionDetails[i].paymentReference,
        conversionDetails[i].feeAmount,
        _feeAddress,
        conversionDetails[i].maxRateTimespan
      );
    }

    // Check that batch contract has enough funds to pay batch conversion fees
    uint256 amountBatchFees = (((contractBalance - address(this).balance)) * batchConversionFee) /
      tenThousand;
    require(address(this).balance >= amountBatchFees, 'not enough funds for batch conversion fees');

    // Batch contract pays batch fee
    _feeAddress.transfer(amountBatchFees);

    // Batch contract transfers the remaining ethers to the payer
    (bool sendBackSuccess, ) = payable(msg.sender).call{value: address(this).balance}('');
    require(sendBackSuccess, 'Could not send remaining funds to the payer');
    payerAuthorized = false;
  }

  /*
   * Admin functions to edit the conversion proxies address and fees
   */

  /**
   * @notice fees added when using Erc20/Eth conversion batch functions
   * @param _batchConversionFee between 0 and 10000, i.e: batchFee = 50 represent 0.50% of fees
   */
  function setBatchConversionFee(uint256 _batchConversionFee) external onlyOwner {
    batchConversionFee = _batchConversionFee;
  }

  /**
   * @param _paymentErc20ConversionProxy The address of the ERC20 Conversion payment proxy to use.
   *        Update cautiously, the proxy has to match the invoice proxy.
   */
  function setPaymentErc20ConversionProxy(address _paymentErc20ConversionProxy) external onlyOwner {
    paymentErc20ConversionProxy = IERC20ConversionProxy(_paymentErc20ConversionProxy);
  }

  /**
   * @param _paymentEthConversionProxy The address of the Ethereum Conversion payment proxy to use.
   *        Update cautiously, the proxy has to match the invoice proxy.
   */
  function setPaymentEthConversionProxy(address _paymentEthConversionProxy) external onlyOwner {
    paymentEthConversionProxy = IEthConversionProxy(_paymentEthConversionProxy);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20ConversionProxy {
  // Event to declare a conversion with a reference
  event TransferWithConversionAndReference(
    uint256 amount,
    address currency,
    bytes indexed paymentReference,
    uint256 feeAmount,
    uint256 maxRateTimespan
  );

  // Event to declare a transfer with a reference
  event TransferWithReferenceAndFee(
    address tokenAddress,
    address to,
    uint256 amount,
    bytes indexed paymentReference,
    uint256 feeAmount,
    address feeAddress
  );

  function transferFromWithReferenceAndFee(
    address _to,
    uint256 _requestAmount,
    address[] calldata _path,
    bytes calldata _paymentReference,
    uint256 _feeAmount,
    address _feeAddress,
    uint256 _maxToSpend,
    uint256 _maxRateTimespan
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IEthConversionProxy
 * @notice This contract converts from chainlink then swaps ETH (or native token)
 *         before paying a request thanks to a conversion payment proxy.
 *         The inheritance from ReentrancyGuard is required to perform
 *         "transferExactEthWithReferenceAndFee" on the eth-fee-proxy contract
 */
interface IEthConversionProxy {
  // Event to declare a conversion with a reference
  event TransferWithConversionAndReference(
    uint256 amount,
    address currency,
    bytes indexed paymentReference,
    uint256 feeAmount,
    uint256 maxRateTimespan
  );

  // Event to declare a transfer with a reference
  // This event is emitted by this contract from a delegate call of the payment-proxy
  event TransferWithReferenceAndFee(
    address to,
    uint256 amount,
    bytes indexed paymentReference,
    uint256 feeAmount,
    address feeAddress
  );

  /**
   * @notice Performs an ETH transfer with a reference computing the payment amount based on the request amount
   * @param _to Transfer recipient of the payement
   * @param _requestAmount Request amount
   * @param _path Conversion path
   * @param _paymentReference Reference of the payment related
   * @param _feeAmount The amount of the payment fee
   * @param _feeAddress The fee recipient
   * @param _maxRateTimespan Max time span with the oldestrate, ignored if zero
   */
  function transferWithReferenceAndFee(
    address _to,
    uint256 _requestAmount,
    address[] calldata _path,
    bytes calldata _paymentReference,
    uint256 _feeAmount,
    address _feeAddress,
    uint256 _maxRateTimespan
  ) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './lib/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './interfaces/ERC20FeeProxy.sol';
import './interfaces/EthereumFeeProxy.sol';

/**
 * @title BatchNoConversionPayments
 * @notice  This contract makes multiple payments with references, in one transaction:
 *          - on: ERC20 Payment Proxy and ETH Payment Proxy of the Request Network protocol
 *          - to: multiple addresses
 *          - fees: ERC20 and ETH proxies fees are paid to the same address.
 *                  An additional batch fee is paid to the same address.
 *         If one transaction of the batch fail, every transactions are reverted.
 * @dev It is a clone of BatchPayment.sol, with three main modifications:
 *         - function "receive" has one other condition: payerAuthorized
 *         - fees are now divided by 10_000 instead of 1_000 in previous version
 *         - batch payment functions have new names and are now public, instead of external
 */
contract BatchNoConversionPayments is Ownable {
  using SafeERC20 for IERC20;

  IERC20FeeProxy public paymentErc20Proxy;
  IEthereumFeeProxy public paymentEthProxy;

  uint256 public batchFee;
  /** Used to to calculate batch fees */
  uint256 internal tenThousand = 10000;

  // payerAuthorized is set to true only when needed for batch Eth conversion
  bool internal payerAuthorized;

  // transferBackRemainingEth is set to false only if the payer use batchRouter
  // and call both batchEthPayments and batchConversionEthPaymentsWithReference
  bool internal transferBackRemainingEth = true;

  struct Token {
    address tokenAddress;
    uint256 amountAndFee;
    uint256 batchFeeAmount;
  }

  /**
   * @param _paymentErc20Proxy The address to the ERC20 fee payment proxy to use.
   * @param _paymentEthProxy The address to the Ethereum fee payment proxy to use.
   * @param _owner Owner of the contract.
   */
  constructor(
    address _paymentErc20Proxy,
    address _paymentEthProxy,
    address _owner
  ) {
    paymentErc20Proxy = IERC20FeeProxy(_paymentErc20Proxy);
    paymentEthProxy = IEthereumFeeProxy(_paymentEthProxy);
    transferOwnership(_owner);
    batchFee = 0;
  }

  /**
   * This contract is non-payable. Making an ETH payment with conversion requires the contract to accept incoming ETH.
   * @dev See the end of `paymentEthConversionProxy.transferWithReferenceAndFee` where the leftover is given back.
   */
  receive() external payable {
    require(payerAuthorized || msg.value == 0, 'Non-payable');
  }

  /**
   * @notice Send a batch of ETH (or EVM native token) payments with fees and paymentReferences to multiple accounts.
   *         If one payment fails, the whole batch reverts.
   * @param _recipients List of recipient accounts.
   * @param _amounts List of amounts, matching recipients[].
   * @param _paymentReferences List of paymentRefs, matching recipients[].
   * @param _feeAmounts List fee amounts, matching recipients[].
   * @param _feeAddress The fee recipient.
   * @dev It uses EthereumFeeProxy to pay an invoice and fees with a payment reference.
   *      Make sure: msg.value >= sum(_amouts)+sum(_feeAmounts)+sumBatchFeeAmount
   */
  function batchEthPayments(
    address[] calldata _recipients,
    uint256[] calldata _amounts,
    bytes[] calldata _paymentReferences,
    uint256[] calldata _feeAmounts,
    address payable _feeAddress
  ) public payable {
    require(
      _recipients.length == _amounts.length &&
        _recipients.length == _paymentReferences.length &&
        _recipients.length == _feeAmounts.length,
      'the input arrays must have the same length'
    );

    // amount is used to get the total amount and then used as batch fee amount
    uint256 amount = 0;

    // Batch contract pays the requests thourgh EthFeeProxy
    for (uint256 i = 0; i < _recipients.length; i++) {
      require(address(this).balance >= _amounts[i] + _feeAmounts[i], 'not enough funds');
      amount += _amounts[i];

      paymentEthProxy.transferWithReferenceAndFee{value: _amounts[i] + _feeAmounts[i]}(
        payable(_recipients[i]),
        _paymentReferences[i],
        _feeAmounts[i],
        payable(_feeAddress)
      );
    }

    // amount is updated into batch fee amount
    amount = (amount * batchFee) / tenThousand;
    // Check that batch contract has enough funds to pay batch fee
    require(address(this).balance >= amount, 'not enough funds for batch fee');
    // Batch pays batch fee
    _feeAddress.transfer(amount);

    // Batch contract transfers the remaining ethers to the payer
    if (transferBackRemainingEth && address(this).balance > 0) {
      (bool sendBackSuccess, ) = payable(msg.sender).call{value: address(this).balance}('');
      require(sendBackSuccess, 'Could not send remaining funds to the payer');
    }
  }

  /**
   * @notice Send a batch of ERC20 payments with fees and paymentReferences to multiple accounts.
   * @param _tokenAddress Token used for all the payments.
   * @param _recipients List of recipient accounts.
   * @param _amounts List of amounts, matching recipients[].
   * @param _paymentReferences List of paymentRefs, matching recipients[].
   * @param _feeAmounts List of payment fee amounts, matching recipients[].
   * @param _feeAddress The fee recipient.
   * @dev Uses ERC20FeeProxy to pay an invoice and fees, with a payment reference.
   *      Make sure this contract has enough allowance to spend the payer's token.
   *      Make sure the payer has enough tokens to pay the amount, the fee, and the batch fee.
   */
  function batchERC20Payments(
    address _tokenAddress,
    address[] calldata _recipients,
    uint256[] calldata _amounts,
    bytes[] calldata _paymentReferences,
    uint256[] calldata _feeAmounts,
    address _feeAddress
  ) public {
    require(
      _recipients.length == _amounts.length &&
        _recipients.length == _paymentReferences.length &&
        _recipients.length == _feeAmounts.length,
      'the input arrays must have the same length'
    );

    // amount is used to get the total amount and fee, and then used as batch fee amount
    uint256 amount = 0;
    for (uint256 i = 0; i < _recipients.length; i++) {
      amount += _amounts[i] + _feeAmounts[i];
    }

    // Transfer the amount and fee from the payer to the batch contract
    IERC20 requestedToken = IERC20(_tokenAddress);
    require(
      requestedToken.allowance(msg.sender, address(this)) >= amount,
      'Insufficient allowance for batch to pay'
    );
    require(requestedToken.balanceOf(msg.sender) >= amount, 'not enough funds');
    require(
      safeTransferFrom(_tokenAddress, address(this), amount),
      'payment transferFrom() failed'
    );

    // Batch contract approve Erc20FeeProxy to spend the token
    if (requestedToken.allowance(address(this), address(paymentErc20Proxy)) < amount) {
      approvePaymentProxyToSpend(address(requestedToken), address(paymentErc20Proxy));
    }

    // Batch contract pays the requests using Erc20FeeProxy
    for (uint256 i = 0; i < _recipients.length; i++) {
      // amount is updated to become the sum of amounts, to calculate batch fee amount
      amount -= _feeAmounts[i];
      paymentErc20Proxy.transferFromWithReferenceAndFee(
        _tokenAddress,
        _recipients[i],
        _amounts[i],
        _paymentReferences[i],
        _feeAmounts[i],
        _feeAddress
      );
    }

    // amount is updated into batch fee amount
    amount = (amount * batchFee) / tenThousand;
    // Check if the payer has enough funds to pay batch fee
    require(requestedToken.balanceOf(msg.sender) >= amount, 'not enough funds for the batch fee');

    // Payer pays batch fee amount
    require(
      safeTransferFrom(_tokenAddress, _feeAddress, amount),
      'batch fee transferFrom() failed'
    );
  }

  /**
   * @notice Send a batch of ERC20 payments with fees and paymentReferences to multiple accounts, with multiple tokens.
   * @param _tokenAddresses List of tokens to transact with.
   * @param _recipients List of recipient accounts.
   * @param _amounts List of amounts, matching recipients[].
   * @param _paymentReferences List of paymentRefs, matching recipients[].
   * @param _feeAmounts List of amounts of the payment fee, matching recipients[].
   * @param _feeAddress The fee recipient.
   * @dev It uses ERC20FeeProxy to pay an invoice and fees, with a payment reference.
   *      Make sure this contract has enough allowance to spend the payer's token.
   *      Make sure the payer has enough tokens to pay the amount, the fee, and the batch fee.
   */
  function batchMultiERC20Payments(
    address[] calldata _tokenAddresses,
    address[] calldata _recipients,
    uint256[] calldata _amounts,
    bytes[] calldata _paymentReferences,
    uint256[] calldata _feeAmounts,
    address _feeAddress
  ) public {
    require(
      _tokenAddresses.length == _recipients.length &&
        _tokenAddresses.length == _amounts.length &&
        _tokenAddresses.length == _paymentReferences.length &&
        _tokenAddresses.length == _feeAmounts.length,
      'the input arrays must have the same length'
    );

    // Create a list of unique tokens used and the amounts associated
    // Only considere tokens having: amounts + feeAmounts > 0
    // batchFeeAmount is the amount's sum, and then, batch fee rate is applied
    Token[] memory uTokens = new Token[](_tokenAddresses.length);
    for (uint256 i = 0; i < _tokenAddresses.length; i++) {
      for (uint256 j = 0; j < _tokenAddresses.length; j++) {
        // If the token is already in the existing uTokens list
        if (uTokens[j].tokenAddress == _tokenAddresses[i]) {
          uTokens[j].amountAndFee += _amounts[i] + _feeAmounts[i];
          uTokens[j].batchFeeAmount += _amounts[i];
          break;
        }
        // If the token is not in the list (amountAndFee = 0), and amount + fee > 0
        if (uTokens[j].amountAndFee == 0 && (_amounts[i] + _feeAmounts[i]) > 0) {
          uTokens[j].tokenAddress = _tokenAddresses[i];
          uTokens[j].amountAndFee = _amounts[i] + _feeAmounts[i];
          uTokens[j].batchFeeAmount = _amounts[i];
          break;
        }
      }
    }

    // The payer transfers tokens to the batch contract and pays batch fee
    for (uint256 i = 0; i < uTokens.length && uTokens[i].amountAndFee > 0; i++) {
      uTokens[i].batchFeeAmount = (uTokens[i].batchFeeAmount * batchFee) / tenThousand;
      IERC20 requestedToken = IERC20(uTokens[i].tokenAddress);

      require(
        requestedToken.allowance(msg.sender, address(this)) >=
          uTokens[i].amountAndFee + uTokens[i].batchFeeAmount,
        'Insufficient allowance for batch to pay'
      );
      // check if the payer can pay the amount, the fee, and the batchFee
      require(
        requestedToken.balanceOf(msg.sender) >= uTokens[i].amountAndFee + uTokens[i].batchFeeAmount,
        'not enough funds'
      );

      // Transfer only the amount and fee required for the token on the batch contract
      require(
        safeTransferFrom(uTokens[i].tokenAddress, address(this), uTokens[i].amountAndFee),
        'payment transferFrom() failed'
      );

      // Batch contract approves Erc20FeeProxy to spend the token
      if (
        requestedToken.allowance(address(this), address(paymentErc20Proxy)) <
        uTokens[i].amountAndFee
      ) {
        approvePaymentProxyToSpend(address(requestedToken), address(paymentErc20Proxy));
      }

      // Payer pays batch fee amount
      require(
        safeTransferFrom(uTokens[i].tokenAddress, _feeAddress, uTokens[i].batchFeeAmount),
        'batch fee transferFrom() failed'
      );
    }

    // Batch contract pays the requests using Erc20FeeProxy
    for (uint256 i = 0; i < _recipients.length; i++) {
      paymentErc20Proxy.transferFromWithReferenceAndFee(
        _tokenAddresses[i],
        _recipients[i],
        _amounts[i],
        _paymentReferences[i],
        _feeAmounts[i],
        _feeAddress
      );
    }
  }

  /*
   * Helper functions
   */

  /**
   * @notice Authorizes the proxy to spend a new request currency (ERC20).
   * @param _erc20Address Address of an ERC20 used as the request currency.
   * @param _paymentErc20Proxy Address of the proxy.
   */
  function approvePaymentProxyToSpend(address _erc20Address, address _paymentErc20Proxy) internal {
    IERC20 erc20 = IERC20(_erc20Address);
    uint256 max = 2**256 - 1;
    erc20.safeApprove(address(_paymentErc20Proxy), max);
  }

  /**
   * @notice Call transferFrom ERC20 function and validates the return data of a ERC20 contract call.
   * @dev This is necessary because of non-standard ERC20 tokens that don't have a return value.
   * @return result The return value of the ERC20 call, returning true for non-standard tokens
   */
  function safeTransferFrom(
    address _tokenAddress,
    address _to,
    uint256 _amount
  ) internal returns (bool result) {
    /* solium-disable security/no-inline-assembly */
    // check if the address is a contract
    assembly {
      if iszero(extcodesize(_tokenAddress)) {
        revert(0, 0)
      }
    }

    // solium-disable-next-line security/no-low-level-calls
    (bool success, ) = _tokenAddress.call(
      abi.encodeWithSignature('transferFrom(address,address,uint256)', msg.sender, _to, _amount)
    );

    assembly {
      switch returndatasize()
      case 0 {
        // Not a standard erc20
        result := 1
      }
      case 32 {
        // Standard erc20
        returndatacopy(0, 0, 32)
        result := mload(0)
      }
      default {
        // Anything else, should revert for safety
        revert(0, 0)
      }
    }

    require(success, 'transferFrom() has been reverted');

    /* solium-enable security/no-inline-assembly */
    return result;
  }

  /*
   * Admin functions to edit the proxies address and fees
   */

  /**
   * @notice fees added when using Erc20/Eth batch functions
   * @param _batchFee between 0 and 10000, i.e: batchFee = 50 represent 0.50% of fee
   */
  function setBatchFee(uint256 _batchFee) external onlyOwner {
    batchFee = _batchFee;
  }

  /**
   * @param _paymentErc20Proxy The address to the Erc20 fee payment proxy to use.
   */
  function setPaymentErc20Proxy(address _paymentErc20Proxy) external onlyOwner {
    paymentErc20Proxy = IERC20FeeProxy(_paymentErc20Proxy);
  }

  /**
   * @param _paymentEthProxy The address to the Ethereum fee payment proxy to use.
   */
  function setPaymentEthProxy(address _paymentEthProxy) external onlyOwner {
    paymentEthProxy = IEthereumFeeProxy(_paymentEthProxy);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * @title SafeERC20
 * @notice Works around implementations of ERC20 with transferFrom not returning success status.
 */
library SafeERC20 {
  /**
   * @notice Call transferFrom ERC20 function and validates the return data of a ERC20 contract call.
   * @dev This is necessary because of non-standard ERC20 tokens that don't have a return value.
   * @return result The return value of the ERC20 call, returning true for non-standard tokens
   */
  function safeTransferFrom(
    IERC20 _token,
    address _from,
    address _to,
    uint256 _amount
  ) internal returns (bool result) {
    // solium-disable-next-line security/no-low-level-calls
    (bool success, bytes memory data) = address(_token).call(
      abi.encodeWithSignature('transferFrom(address,address,uint256)', _from, _to, _amount)
    );

    return success && (data.length == 0 || abi.decode(data, (bool)));
  }

  /**
   * @notice Call approve ERC20 function and validates the return data of a ERC20 contract call.
   * @dev This is necessary because of non-standard ERC20 tokens that don't have a return value.
   * @return result The return value of the ERC20 call, returning true for non-standard tokens
   */
  function safeApprove(
    IERC20 _token,
    address _spender,
    uint256 _amount
  ) internal returns (bool result) {
    // solium-disable-next-line security/no-low-level-calls
    (bool success, bytes memory data) = address(_token).call(
      abi.encodeWithSignature('approve(address,uint256)', _spender, _amount)
    );

    return success && (data.length == 0 || abi.decode(data, (bool)));
  }

  /**
   * @notice Call transfer ERC20 function and validates the return data of a ERC20 contract call.
   * @dev This is necessary because of non-standard ERC20 tokens that don't have a return value.
   * @return result The return value of the ERC20 call, returning true for non-standard tokens
   */
  function safeTransfer(
    IERC20 _token,
    address _to,
    uint256 _amount
  ) internal returns (bool result) {
    // solium-disable-next-line security/no-low-level-calls
    (bool success, bytes memory data) = address(_token).call(
      abi.encodeWithSignature('transfer(address,uint256)', _to, _amount)
    );

    return success && (data.length == 0 || abi.decode(data, (bool)));
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20FeeProxy {
  event TransferWithReferenceAndFee(
    address tokenAddress,
    address to,
    uint256 amount,
    bytes indexed paymentReference,
    uint256 feeAmount,
    address feeAddress
  );

  function transferFromWithReferenceAndFee(
    address _tokenAddress,
    address _to,
    uint256 _amount,
    bytes calldata _paymentReference,
    uint256 _feeAmount,
    address _feeAddress
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEthereumFeeProxy {
  event TransferWithReferenceAndFee(
    address to,
    uint256 amount,
    bytes indexed paymentReference,
    uint256 feeAmount,
    address feeAddress
  );

  function transferWithReferenceAndFee(
    address payable _to,
    bytes calldata _paymentReference,
    uint256 _feeAmount,
    address payable _feeAddress
  ) external payable;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}