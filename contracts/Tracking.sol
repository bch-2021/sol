// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./ERC/ERCTracking.sol";

/// @title Tracking
contract Tracking is ERCTracking {
    constructor(
        string memory _name,
        string memory _headquarters,
        string memory _description,
        uint256[] memory _transferTypes
    ) ERCTracking(_name, _headquarters, _description, _transferTypes) public {}
}
