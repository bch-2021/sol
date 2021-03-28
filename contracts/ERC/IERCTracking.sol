// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

/// @title IERCTracking
interface IERCTracking {
    /// @notice Information about product that transferred to the some point
    struct ProductTransfer {
        uint256 pointId;
        uint256 date;
        string link;
        uint256 transferType;
    }
    /// @param _name Info. Real point name (Fabric, Retail point...)
    /// @param _pointAddress Info. Real address
    /// @param _pointOwner Address that can create product transfer
    function createPoint(string memory _name, string memory _pointAddress, address _pointOwner) external;

    /// @notice Update point information
    /// @param _pointId Point ID
    /// @param _name New name
    /// @param _pointAddress New address
    function updatePoint(uint256 _pointId, string memory _name, string memory _pointAddress) external;

    /// @notice Transfer point ownership. Only point owner address can create product transfer
    /// @param _pointId Point identificator
    /// @param _newPointOwner New point ownership address
    function transferPointOwnership(uint256 _pointId, address _newPointOwner) external;

    /// @notice Create product transaction. Related to Point.
    /// @param _pointId Point identificator
    /// @param _link Link to product serial numbers on IPFS
    /// @param _transferType One of transfer types
    /// @param _batchNumber Batch number
    function createProductTransfer(
        uint256 _pointId,
        string memory _link,
        uint256 _transferType,
        string memory _batchNumber
    ) external;

    /// @param _batchNumber Batch number of the product transfer
    /// @return Product transfer for selected batch number
    function getInfoByBatchNumber(string memory _batchNumber) external view returns(ProductTransfer[] memory);

    /// @return All batch numbers
    function getBatchNumbers() external view returns(string[] memory);
}
