const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Montserrat'],
      },
      colors: {
        brand: {
          primary: '#933a35',
          secondary: '#6B6B6B',
          background: '#FAF7F4',
          white: '#FFFFFF',
          field: '#EDE1D5',
          error: '#FDF0EE',
          muted: '#D18D83',
          divider: '#DDD0CB',
          dark: '#3d2b28',
        },
        phase: {
          menstrual: '#933a35',
          follicular: '#D18D83',
          ovulation: '#F5C6AD',
          luteal: '#EDE1D5',
        }
      },
      maxWidth: {
        'app': '430px',
      }
    },
  },
  plugins: [
  ]
}
