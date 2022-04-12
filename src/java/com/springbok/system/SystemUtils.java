package com.springbok.system;

import Jama.Matrix;

import java.util.*;
import java.util.stream.Collectors;

public class SystemUtils {

    protected static class ArrayMinMax {
        private double[] values;
        private int[] indexes;

        public ArrayMinMax(double[] values, int[] indexes) {
            this.values = values;
            this.indexes = indexes;
        }

        public double[] getValues() {
            return values;
        }

        public int[] getIndexes() {
            return indexes;
        }
    }

    public static double[] negativeInf(int n) {
        double[] vector = new double[n];
        for (int j = 0; j < n; j++) {
            vector[j] = Double.NEGATIVE_INFINITY;
        }
        return vector;
    }

    public static int[] randperm(int size) {
        List<Integer> list = new ArrayList<>();
        for (int i = 1; i <= size; i++) {
            list.add(i);
        }
        Collections.shuffle(list);
        return list.stream().mapToInt(i -> i).toArray();
    }

    public static double[][] getNanArray(int n, int m) {
        double[][] result = new double[n][m];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                result[i][j] = Double.NaN;
            }
        }
        return result;
    }

    public static Matrix sqrt(Matrix matrix) {
        double[][] result = new double[matrix.getRowDimension()][matrix.getColumnDimension()];
        for (int i = 0; i < matrix.getRowDimension(); i++) {
            for (int j = 0; j < matrix.getColumnDimension(); j++) {
                result[i][j] = Math.sqrt(matrix.get(i, j));
            }
        }
        return new Matrix(result);
    }

    public static boolean[][] isnan(double[][] array) {
        boolean[][] result = new boolean[array.length][array[0].length];
        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array[0].length; j++) {
                result[i][j] = Double.isNaN(array[i][j]);
            }
        }
        return result;
    }

    public static boolean[][] notIsnan(double[][] array) {
        boolean[][] result = new boolean[array.length][array[0].length];
        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array[0].length; j++) {
                result[i][j] = !Double.isNaN(array[i][j]);
            }
        }
        return result;
    }

    public static double[][] positiveInfArr(double[][] array, boolean[][] indexes) {
        if (array.length != indexes.length && array[0].length != indexes[0].length) {
            throw new RuntimeException("Not possible to work with different matrix dimensions");
        }
        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array[0].length; j++) {
                if (indexes[i][j]) {
                    array[i][j] = Double.POSITIVE_INFINITY;
                }
            }
        }
        return array;
    }

    public static double[][] negativeInfArr(double[][] array, boolean[][] indexes) {
        if (array.length != indexes.length && array[0].length != indexes[0].length) {
            throw new RuntimeException("Not possible to work with different matrix dimensions");
        }
        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array[0].length; j++) {
                if (indexes[i][j]) {
                    array[i][j] = Double.NEGATIVE_INFINITY;
                }
            }
        }
        return array;
    }

    public static ArrayMinMax min(double[][] array) {
        int[] indexes = new int[array[0].length];
        double[] minValues = new double[array[0].length];

        for (int i = 0; i < array[0].length; i++) {
            int index = 1;
            double value = array[0][i];
            for (int j = 0; j < array.length; j++) {
                if (value > array[j][i]) {
                    index = i + 1;
                    value = array[i][j];
                }
            }
            indexes[i] = index;
            minValues[i] = value;
        }

        return new ArrayMinMax(minValues, indexes);
    }

    public static ArrayMinMax max(double[][] array) {
        int[] indexes = new int[array[0].length];
        double[] maxValues = new double[array[0].length];

        for (int i = 0; i < array[0].length; i++) {
            int index = 1;
            double value = array[0][i];
            for (int j = 0; j < array.length; j++) {
                if (value > array[j][i]) {
                    index = i + 1;
                    value = array[i][j];
                }
            }
            indexes[i] = index;
            maxValues[i] = value;
        }

        return new ArrayMinMax(maxValues, indexes);
    }

    public static ArrayMinMax max(double[] array) {
        int index = 1;
        double value = array[0];
        for (int i = 1; i < array.length; i++) {
            if (array[i] < value) {
                value = array[i];
                index = i + 1;
            }
        }

        return new ArrayMinMax(new double[]{value}, new int[index]);
    }

    public static int[] find(boolean[][] array) {
        List<Integer> list = new ArrayList<>();
        int counter = 1;
        for (int i = 0; i < array[0].length; i++) {
            for (int j = 0; j < array.length; j++, counter++) {
                if (array[j][i]) {
                    list.add(counter);
                }
            }
        }
        return list.stream().mapToInt(Integer::intValue).toArray();
    }

    public static int[] findReverse(int[] array) {
        List<Integer> list = new ArrayList<>();
        int counter = 1;
        for (int j = 0; j < array.length; j++, counter++) {
            if (array[j] == 0) {
                list.add(counter);
            }
        }
        return list.stream().mapToInt(Integer::intValue).toArray();
    }

    public static Network[] eliminateEmpty(Network[] networks, int[] indexes) {
        List<Network> list = new LinkedList<>(Arrays.asList(networks));

        for (int i = 0; i < indexes.length; i++) {
            list.remove(indexes[i] - 1);
        }
        return list.toArray(new Network[networks.length - indexes.length]);
    }

    public static int[] eliminateEmpty(int[] array, int[] indexes) {
        List<Integer> list = Arrays.stream(array).boxed().collect(Collectors.toList());
        for (int i = 0; i < indexes.length; i++) {
            list.remove(indexes[i] - 1);
        }
        return list.stream().mapToInt(Integer::intValue).toArray();
    }

    public static int[] unique(int[] array) {
        return Arrays.stream(array).distinct().toArray();
    }

    public static int[][] findUniqueBiggerThenZero(int[][] array) {
        int[][] result = new int[array.length][array[0].length];
        for (int i = 0; i < array[0].length; i++) {
            for (int j = 0; j < array.length; j++) {
                if (array[j][i] > 0) {
                    result[j][i] = array[j][i];
                }
            }
        }
        for (int i = 0; i < result.length; i++) {
            result[i] = unique(result[i]);
        }
        return result;
    }

    public static int[][] reshape(int[][] array, int n, int m) {
        int[] buffer = new int[n * m];
        int newIndex = 0;
        for (int i = 0; i < array[0].length; i++) {
            for (int j = 0; j < array.length; j++, newIndex++) {
                buffer[newIndex] = array[j][i];
            }
        }

        newIndex = 0;
        int[][] result = new int[n][m];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++, newIndex++) {
                result[i][j] = buffer[newIndex];
            }
        }
        return result;
    }

}
