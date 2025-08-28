import React, { useEffect, useState } from 'react';
import axios from 'axios';
import CategoryCard from './../../components/categoryCard';

const Categories = () => {
  const [categories, setCategories] = useState([]);

  const fetchCategories = async () => {
    try {
      const res = await axios.get('http://localhost:8080/api/categories');
      setCategories(res.data.categories);
    } catch (err) {
      console.error('Error fetching categories:', err);
    }
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  return (
    <div className="flex flex-col items-center p-6 w-full">
      <h1 className="text-2xl font-bold mb-2">Saviya B2B E-Commerce Application</h1>
      <div className="bg-[#565449] h-1 w-full mb-6"></div>

      <div className="flex justify-between items-center w-full max-w-2xl mb-4 px-2">
        <p className="text-xl font-semibold">Categories</p>
        {/* Removed Add Category button */}
      </div>

      <div className="grid gap-4 w-full max-w-2xl">
        {categories.map((category) => (
          <CategoryCard
            key={category.categoryid}
            category={category}
            onUpdate={fetchCategories} // Keep this for refreshing after edit
          // Removed onDelete prop
          />
        ))}
      </div>
    </div>
  );
};

export default Categories;
