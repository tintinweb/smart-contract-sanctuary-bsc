/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICalculator {
  enum OperationType {
    Addition,
    Subtraction,
    Multiplication,
    Dividing
  }

  function addition(uint256 varaible1, uint256 variable2) external;

  function subtraction(uint256 varaible1, uint256 variable2) external;

  function multiplication(uint256 varaible1, uint256 variable2) external;

  function dividing(uint256 varaible1, uint256 variable2) external;

  event UpdateResult(uint256 variable1, uint256 variable2, OperationType indexed operation);
}

contract Calculator is ICalculator {
  uint256 public lastResult;

  modifier checkVariable2(uint256 variable2) {
    require(variable2 != 0, "variable2 cannot be equel zero");
    _;
  }

  function addition(uint256 variable1, uint256 variable2) external override {
    lastResult = variable1 + variable2;
    emit UpdateResult(variable1, variable2, OperationType.Addition);
  }

  function subtraction(uint256 variable1, uint256 variable2) external override {
    lastResult = variable1 - variable2;
    emit UpdateResult(variable1, variable2, OperationType.Subtraction);
  }

  function multiplication(uint256 variable1, uint256 variable2) external override {
    lastResult = variable1 * variable2;
    emit UpdateResult(variable1, variable2, OperationType.Multiplication);
  }

  function dividing(uint256 variable1, uint256 variable2) external override checkVariable2(variable2) {
    lastResult = variable1 / variable2;
    emit UpdateResult(variable1, variable2, OperationType.Dividing);
  }
}